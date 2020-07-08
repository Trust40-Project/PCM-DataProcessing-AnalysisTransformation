package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.tests;

import static org.hamcrest.Matchers.empty;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.MatcherAssert.assertThat;

import java.io.IOException;
import java.util.Collection;
import java.util.Collections;

import org.eclipse.emf.common.util.Diagnostic;
import org.eclipse.emf.compare.Comparison;
import org.eclipse.emf.compare.EMFCompare;
import org.eclipse.emf.compare.scope.DefaultComparisonScope;
import org.eclipse.emf.compare.scope.IComparisonScope;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.util.Diagnostician;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.junit.Test;
import org.palladiosimulator.pcm.allocation.Allocation;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics.IReturnValueAssignmentGenerator;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.tests.base.TransformationTestBase;
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.DataSpecification;
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.characteristics.CharacteristicTypeContainer;
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.Operation;
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.Variable;
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.VariableAssignment;
import org.palladiosimulator.pcm.usagemodel.UsageModel;

public class TransformationTest extends TransformationTestBase {

	public TransformationTest() {
		super("org.palladiosimulator.pcm.dataprocessing.analysis.transformation.tests");
	}

	@Override
	protected Collection<IReturnValueAssignmentGenerator> getAdditionalGenerators() {
		return Collections.emptyList();
	}

	@Test
	public void testMinimalEcho() throws IOException {
		ResourceSet rs = new ResourceSetImpl();
		UsageModel usageModel = (UsageModel) rs
				.getResource(createRelativeURI("models/minimalCallAndReturn/newUsageModel.usagemodel"), true)
				.getContents().get(0);
		Allocation allocationModel = (Allocation) rs
				.getResource(createRelativeURI("models/minimalCallAndReturn/newAllocation.allocation"), true)
				.getContents().get(0);
		CharacteristicTypeContainer characteristicTypeContainer = (CharacteristicTypeContainer) rs
				.getResource(createRelativeURI("models/minimalCallAndReturn/characteristicTypes.xmi"), true)
				.getContents().get(0);
		DataSpecification ds = (DataSpecification) rs
				.getResource(createRelativeURI("models/minimalCallAndReturn/DataSpecification.xmi"), true)
				.getContents().get(0);
		EcoreUtil.resolveAll(rs);

		org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.System dataFlowSystemModel = getSubject().transform(usageModel,
				allocationModel, characteristicTypeContainer);

		Diagnostic validationResult2 = Diagnostician.INSTANCE.validate(ds);
		assertThat(toString(validationResult2), validationResult2.getSeverity(), is(Diagnostic.OK));
		Diagnostic validationResult = Diagnostician.INSTANCE.validate(dataFlowSystemModel);
		assertThat(toString(validationResult), validationResult.getSeverity(), is(Diagnostic.OK));

		assertThat(dataFlowSystemModel.getSystemusages(), hasSize(1));
		assertThat(dataFlowSystemModel.getSystemusages().get(0).getCalls(), hasSize(1));

		Operation systemUsageOperation = dataFlowSystemModel.getSystemusages().get(0).getCalls().get(0).getCallee();
		assertThat(systemUsageOperation.getCalls(), hasSize(1));

		Operation consumeOperation = systemUsageOperation.getCalls().get(0).getCallee();
		assertThat(consumeOperation.getReturnValues(), is(empty()));
		assertThat(consumeOperation.getCalls(), hasSize(1));

		Operation transmitOperation = consumeOperation.getCalls().get(0).getCallee();
		assertThat(transmitOperation.getReturnValues(), hasSize(1));
		assertThat(transmitOperation.getCalls(), hasSize(2));
		assertThat(transmitOperation.getCalls().get(1).getPreCallStateDefinitions(), hasSize(1));
		assertThat(transmitOperation.getReturnValueAssignments(), hasSize(1));

		Operation createOperation = transmitOperation.getCalls().get(0).getCallee();
		assertThat(createOperation.getCalls(), is(empty()));
		assertThat(createOperation.getReturnValues(), hasSize(1));
		assertThat(createOperation.getReturnValueAssignments(), hasSize(1));

		Operation seffOperation = transmitOperation.getCalls().get(1).getCallee();
		assertThat(seffOperation.getReturnValues(), hasSize(1));
		assertThat(seffOperation.getStateVariables(), hasSize(1));
		assertThat(seffOperation.getParameters(), hasSize(0));
		assertThat(seffOperation.getReturnValueAssignments(), hasSize(1));
		assertThat(seffOperation.getCalls(), hasSize(1));

		Variable createdEchoDataVariable = createOperation.getReturnValues().get(0);
		VariableAssignment stateDef = transmitOperation.getCalls().get(1).getPreCallStateDefinitions().get(0);
		assertFullCopy(stateDef, seffOperation.getStateVariables().get(0), createdEchoDataVariable,
				transmitOperation.getCalls().get(0));

		Operation echoOperation = seffOperation.getCalls().get(0).getCallee();
		assertThat(echoOperation.getReturnValues(), hasSize(1));
		assertThat(echoOperation.getReturnValueAssignments(), hasSize(1));
		assertThat(echoOperation.getCalls(), is(empty()));
		assertThat(echoOperation.getParameters(), is(empty()));

		VariableAssignment echoOperationReturnAssignment = echoOperation.getReturnValueAssignments().get(0);
		assertFullCopy(echoOperationReturnAssignment, echoOperation.getReturnValues().get(0),
				seffOperation.getStateVariables().get(0));

		VariableAssignment seffReturnAssignment = seffOperation.getReturnValueAssignments().get(0);
		assertFullCopy(seffReturnAssignment, seffOperation.getReturnValues().get(0),
				echoOperation.getReturnValues().get(0), seffOperation.getCalls().get(0));

		VariableAssignment transmitOperationReturnAssignment = transmitOperation.getReturnValueAssignments().get(0);
		assertFullCopy(transmitOperationReturnAssignment, transmitOperation.getReturnValues().get(0),
				seffOperation.getReturnValues().get(0), transmitOperation.getCalls().get(1));
	}
	
	@Test
	public void testMinimalSameSignature() throws IOException {
		ResourceSet rs = new ResourceSetImpl();
		UsageModel usageModel = (UsageModel) rs
				.getResource(createRelativeURI("models/minimalSameSignature/newUsageModel.usagemodel"), true)
				.getContents().get(0);
		Allocation allocationModel = (Allocation) rs
				.getResource(createRelativeURI("models/minimalSameSignature/newAllocation.allocation"), true)
				.getContents().get(0);
		CharacteristicTypeContainer characteristicTypeContainer = (CharacteristicTypeContainer) rs
				.getResource(createRelativeURI("models/minimalSameSignature/characteristicTypes.xmi"), true)
				.getContents().get(0);
		EcoreUtil.resolveAll(rs);

		org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.System dataFlowSystemModel = getSubject().transform(usageModel,
				allocationModel, characteristicTypeContainer);

		Diagnostic validationResult = Diagnostician.INSTANCE.validate(dataFlowSystemModel);
		assertThat(toString(validationResult), validationResult.getSeverity(), is(Diagnostic.OK));
		
		Resource expectedResource = rs.getResource(createRelativeURI("models/minimalSameSignature/expected.xmi"), true);

		IComparisonScope scope = new DefaultComparisonScope(expectedResource.getContents().get(0), dataFlowSystemModel, null);
		Comparison comparison = EMFCompare.builder().build().compare(scope);

		assertThat(toString(comparison), comparison.getDifferences(), is(empty()));
	}
	
	@Test
	public void testMinStatic() throws IOException {
		ResourceSet rs = new ResourceSetImpl();
		UsageModel usageModel = (UsageModel) rs
				.getResource(createRelativeURI("models/minStatic/newUsageModel.usagemodel"), true)
				.getContents().get(0);
		Allocation allocationModel = (Allocation) rs
				.getResource(createRelativeURI("models/minStatic/newAllocation.allocation"), true)
				.getContents().get(0);
		DataSpecification dataSpecification = (DataSpecification) rs
				.getResource(createRelativeURI("models/minStatic/newDataProcessing.dataprocessing"), true)
				.getContents().get(0);
		EcoreUtil.resolveAll(rs);
		
		org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.System dataFlowSystemModel = getSubject().transform(usageModel,
				allocationModel, dataSpecification.getCharacteristicTypeContainers().iterator().next());

		Diagnostic validationResult = Diagnostician.INSTANCE.validate(dataFlowSystemModel);
		assertThat(toString(validationResult), validationResult.getSeverity(), is(Diagnostic.OK));
		
		Resource expectedResource = rs.getResource(createRelativeURI("models/minStatic/expected.xmi"), true);

		IComparisonScope scope = new DefaultComparisonScope(expectedResource.getContents().get(0), dataFlowSystemModel, null);
		Comparison comparison = EMFCompare.builder().build().compare(scope);

		assertThat(toString(comparison), comparison.getDifferences(), is(empty()));
	}
	
	@Test
	public void testGeolocation() throws IOException {
		ResourceSet rs = new ResourceSetImpl();
		UsageModel usageModel = (UsageModel) rs
				.getResource(createRelativeURI("models/geoLocation/newUsageModel.usagemodel"), true)
				.getContents().get(0);
		Allocation allocationModel = (Allocation) rs
				.getResource(createRelativeURI("models/geoLocation/newAllocation.allocation"), true)
				.getContents().get(0);
		CharacteristicTypeContainer characteristics = (CharacteristicTypeContainer) rs
				.getResource(createRelativeURI("models/geoLocation/characteristics.xmi"), true)
				.getContents().get(0);
		EcoreUtil.resolveAll(rs);
		
		org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.System dataFlowSystemModel = getSubject().transform(usageModel,
				allocationModel, characteristics);

		Diagnostic validationResult = Diagnostician.INSTANCE.validate(dataFlowSystemModel);
		assertThat(toString(validationResult), validationResult.getSeverity(), is(Diagnostic.OK));
		
		Resource expectedResource = rs.getResource(createRelativeURI("models/geoLocation/expected.xmi"), true);
		
		IComparisonScope scope = new DefaultComparisonScope(expectedResource.getContents().get(0), dataFlowSystemModel, null);
		Comparison comparison = EMFCompare.builder().build().compare(scope);

		assertThat(toString(comparison), comparison.getDifferences(), is(empty()));
	}
	
	@Test
	public void testTrust40Eval() throws IOException {
        ResourceSet rs = new ResourceSetImpl();
        UsageModel usageModel = (UsageModel) rs
            .getResource(createRelativeURI("models/trust40eval/newUsageModel.usagemodel"), true)
            .getContents()
            .get(0);
        Allocation allocationModel = (Allocation) rs
            .getResource(createRelativeURI("models/trust40eval/newAllocation.allocation"), true)
            .getContents()
            .get(0);
        DataSpecification dataSpec = (DataSpecification) rs
            .getResource(createRelativeURI("models/trust40eval/DataSpecification.xmi"), true)
            .getContents()
            .get(0);
        CharacteristicTypeContainer characteristics = dataSpec.getCharacteristicTypeContainers()
            .get(0);
        EcoreUtil.resolveAll(rs);

        org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.System dataFlowSystemModel = getSubject()
            .transform(usageModel, allocationModel, characteristics);

        Diagnostic validationResult = Diagnostician.INSTANCE.validate(dataFlowSystemModel);
        assertThat(toString(validationResult), validationResult.getSeverity(), is(Diagnostic.OK));

        Resource expectedResource = rs.getResource(createRelativeURI("models/trust40eval/expected.xmi"), true);

        IComparisonScope scope = new DefaultComparisonScope(expectedResource.getContents()
            .get(0), dataFlowSystemModel, null);
        Comparison comparison = EMFCompare.builder()
            .build()
            .compare(scope);

        assertThat(toString(comparison), comparison.getDifferences(), is(empty()));
	}
	
}
