package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.rbac.tests;

import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Optional;

import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.junit.Test;
import org.palladiosimulator.mdsdprofiles.api.StereotypeAPI;
import org.palladiosimulator.pcm.allocation.Allocation;
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.DataSpecification;
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.characteristics.CharacteristicTypeContainer;
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.characteristics.EnumCharacteristic;
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.data.Data;
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.effectspecification.DirectCharacteristic;
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.effectspecification.OperationTypeDataProcessingEffect;
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.effectspecification.ProcessingEffect;
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.effectspecification.ProcessingEffectProvider;
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.processing.DataProcessingContainer;
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.processing.PerformDataTransmissionOperation;
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.util.DataMapping;
import org.palladiosimulator.pcm.dataprocessing.profile.api.ProfileConstants;
import org.palladiosimulator.pcm.system.System;
import org.palladiosimulator.pcm.usagemodel.AbstractUserAction;
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall;
import org.palladiosimulator.pcm.usagemodel.UsageModel;

public class TransformationTest extends RBACTransformationTestBase {
	
	@Test
	public void testTravelPlannerSuccess() throws IOException {
		runComparingTransformationTest("travelPlanner");
	}
	
	@Test
	public void testTravelPlannerWithoutDeclassificationSuccess() throws IOException {
		ModelModifier modelModifier = (UsageModel um, System sys, Allocation am, CharacteristicTypeContainer ctc) -> {
			EList<AbstractUserAction> actions = um.getUsageScenario_UsageModel().get(0).getScenarioBehaviour_UsageScenario().getActions_ScenarioBehaviour();
			EntryLevelSystemCall declassifyCall = actions.stream().filter(EntryLevelSystemCall.class::isInstance).map(EntryLevelSystemCall.class::cast).filter(a -> a.getEntityName().toLowerCase().contains("declassify")).findFirst().get();
			AbstractUserAction previousAction = declassifyCall.getPredecessor();
			AbstractUserAction nextAction = declassifyCall.getSuccessor();
			previousAction.setSuccessor(nextAction);
			StereotypeAPI.unapplyStereotype(declassifyCall, ProfileConstants.STEREOTYPE_NAME_DATA_PROCESSING);
			
			EntryLevelSystemCall releaseCCDCall = actions.stream().filter(EntryLevelSystemCall.class::isInstance).map(EntryLevelSystemCall.class::cast).filter(a -> a.getEntityName().toLowerCase().contains("releaseccd")).findFirst().get();
			
			DataProcessingContainer dpcCCD = StereotypeAPI.getTaggedValue(releaseCCDCall, ProfileConstants.TAGGED_VALUE_NAME_DATA_PROCESSING_CONTAINER, ProfileConstants.STEREOTYPE_NAME_DATA_PROCESSING);
			Data ccd = dpcCCD.getOperations().get(0).getOutgoingData().get(0);

			DataProcessingContainer dpcNext = StereotypeAPI.getTaggedValue(nextAction, ProfileConstants.TAGGED_VALUE_NAME_DATA_PROCESSING_CONTAINER, ProfileConstants.STEREOTYPE_NAME_DATA_PROCESSING);
			DataMapping ccdMapping = ((PerformDataTransmissionOperation)dpcNext.getOperations().get(0)).getInputMappings().stream().filter(im -> im.getFrom().getEntityName().toLowerCase().contains("ccd")).findFirst().get();
			ccdMapping.setFrom(ccd);
			
			EcoreUtil.remove(declassifyCall);
		};
		runComparingTransformationTest("travelPlanner", Optional.of(modelModifier), Optional.of("expectedWithoutDeclassification.xmi"), Optional.empty());
	}
	
	@Test
	public void testDistanceTrackerSuccess() throws IOException {
		runComparingTransformationTest("distanceTracker");
	}
	
	@Test
	public void testDistanceTrackerWithoutDeclassificationSuccess() throws IOException {
		ModelModifier modelModifier = (UsageModel um, System sys, Allocation am, CharacteristicTypeContainer ctc) -> {
			EList<AbstractUserAction> actions = um.getUsageScenario_UsageModel().get(0).getScenarioBehaviour_UsageScenario().getActions_ScenarioBehaviour();
			EntryLevelSystemCall declassifyCall = actions.stream().filter(EntryLevelSystemCall.class::isInstance).map(EntryLevelSystemCall.class::cast).filter(a -> "declassify".equals(a.getEntityName())).findFirst().get();
			AbstractUserAction previousAction = declassifyCall.getPredecessor();
			AbstractUserAction nextAction = declassifyCall.getSuccessor();
			previousAction.setSuccessor(nextAction);
			StereotypeAPI.unapplyStereotype(declassifyCall, ProfileConstants.STEREOTYPE_NAME_DATA_PROCESSING);
			
			DataProcessingContainer dpcPrev = StereotypeAPI.getTaggedValue(previousAction, ProfileConstants.TAGGED_VALUE_NAME_DATA_PROCESSING_CONTAINER, ProfileConstants.STEREOTYPE_NAME_DATA_PROCESSING);
			Data distance = dpcPrev.getOperations().get(0).getOutgoingData().get(0);

			DataProcessingContainer dpcNext = StereotypeAPI.getTaggedValue(nextAction, ProfileConstants.TAGGED_VALUE_NAME_DATA_PROCESSING_CONTAINER, ProfileConstants.STEREOTYPE_NAME_DATA_PROCESSING);
			((PerformDataTransmissionOperation)dpcNext.getOperations().get(0)).getInputMappings().get(0).setFrom(distance);
			
			EcoreUtil.remove(declassifyCall);
		};
		runComparingTransformationTest("distanceTracker", Optional.of(modelModifier), Optional.of("expectedWithoutDeclassification.xmi"), Optional.empty());
	}
	
	@Test
	public void testDistanceTrackerWithoutDistanceAccessRightAssignment() throws IOException {
		ModelModifier modelModifier = (UsageModel um, System sys, Allocation am, CharacteristicTypeContainer ctc) -> {
			AbstractUserAction firstAction = um.getUsageScenario_UsageModel().get(0).getScenarioBehaviour_UsageScenario().getActions_ScenarioBehaviour().stream().filter(a -> StereotypeAPI.hasAppliedStereotype(new HashSet<>(Arrays.asList(a)), ProfileConstants.STEREOTYPE_NAME_DATA_PROCESSING)).findAny().get();
			DataProcessingContainer dpc = StereotypeAPI.getTaggedValue(firstAction, ProfileConstants.TAGGED_VALUE_NAME_DATA_PROCESSING_CONTAINER, ProfileConstants.STEREOTYPE_NAME_DATA_PROCESSING);
			ProcessingEffectProvider pep = dpc.getOperations().get(0).getProcessingEffectProvider();
			Optional<ProcessingEffect> aggregateEffect = pep.getProcessingEffects().stream().filter(ef -> ef.getEntityName().equals("aggregateRouteToDistance")).findFirst();
			aggregateEffect.get().getCharacteristicChanges().clear();
		};
		runComparingTransformationTest("distanceTracker", Optional.of(modelModifier), Optional.of("expectedWithoutDistance.xmi"), Optional.empty());
	}
	
	@Test
	public void testContactSMSManager() throws IOException {
		runComparingTransformationTest("contactSMSManager");
	}
	
	@Test
	public void testContactSMSManagerWithoutDeclassification() throws IOException {
		ModelModifier modelModifier = (UsageModel um, System sys, Allocation am, CharacteristicTypeContainer ctc) -> {
			EList<AbstractUserAction> actions = um.getUsageScenario_UsageModel().get(0).getScenarioBehaviour_UsageScenario().getActions_ScenarioBehaviour();
			AbstractUserAction userAction = actions.stream().filter(EntryLevelSystemCall.class::isInstance).findAny().get();
			DataProcessingContainer dpc = StereotypeAPI.getTaggedValue(userAction, ProfileConstants.TAGGED_VALUE_NAME_DATA_PROCESSING_CONTAINER, ProfileConstants.STEREOTYPE_NAME_DATA_PROCESSING);
			DataSpecification ds = (DataSpecification) EcoreUtil.getRootContainer(dpc);
			ProcessingEffect declassificationEffect = ds.getProcessingEffects().stream().filter(OperationTypeDataProcessingEffect.class::isInstance).findFirst().get();
			DirectCharacteristic characteristicSpec = (DirectCharacteristic)declassificationEffect.getCharacteristicChanges().get(0).getCharacteristicSpecifications().get(0);
			EnumCharacteristic characteristic = (EnumCharacteristic)characteristicSpec.getCharacteristic();
			characteristic.getLiterals().clear();
		};
		runComparingTransformationTest("contactSMSManager", Optional.of(modelModifier), Optional.of("expectedWithoutDeclassification.xmi"), Optional.empty());
	}

}
