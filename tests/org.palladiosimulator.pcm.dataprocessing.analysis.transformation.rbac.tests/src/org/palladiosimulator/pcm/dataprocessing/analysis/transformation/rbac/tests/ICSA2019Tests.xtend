package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.rbac.tests

import java.io.IOException
import java.util.LinkedList
import java.util.Optional
import org.eclipse.emf.ecore.util.EcoreUtil
import org.junit.Test
import org.junit.experimental.categories.Category
import org.palladiosimulator.pcm.core.entity.NamedElement
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.DataSpecification
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.characteristics.CharacteristicContainer
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.characteristics.EnumCharacteristic
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.data.DataFactory
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.effectspecification.DataCreationProcessingEffect
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.effectspecification.DirectCharacteristic
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.effectspecification.OperationTypeDataProcessingEffect
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.processing.CreateDataOperation
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.processing.LoadAllDataOperation
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.processing.ProcessingFactory
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.processing.ReturnDataOperation
import org.palladiosimulator.pcm.dataprocessing.profile.api.ProfileConstants
import org.palladiosimulator.pcm.repository.CollectionDataType
import org.palladiosimulator.pcm.repository.CompositeDataType
import org.palladiosimulator.pcm.repository.PrimitiveDataType
import org.palladiosimulator.pcm.usagemodel.UsageModel

import static extension org.palladiosimulator.mdsdprofiles.api.StereotypeAPI.*

class ICSA2019Tests extends RBACTransformationTestBase {

	interface ResultSuccess {}
	interface ResultFailImmediately {}
	interface ResultFailImmediatelyRoles extends ResultFailImmediately {}
	interface ResultFailImmediatelyCreate extends ResultFailImmediately {}
	interface ResultFailImmediatelyLoad extends ResultFailImmediately {} 
	interface ResultFailDataTransfer {}
	interface ResultFailDataProcessing {}
	
	@Test
	@Category(ResultSuccess)
	def testDistanceTrackerSuccess() throws IOException {
		runComparingTransformationTest("distanceTracker");
	}
	
	@Test
	@Category(ResultSuccess)
	def testContactSMSManager() throws IOException {
		runComparingTransformationTest("contactSMSManager");
	}
	
	@Test
	@Category(ResultFailImmediatelyRoles)
	def testEmptyRolesInScenarioBehavior() {
		// remove all roles from usage scenarios
		val ModelModifier modifier = [um, sys, am, ctc | 
			um.usageScenario_UsageModel.forEach[us |
				val characteristicContainer = us.scenarioBehaviour_UsageScenario.getTaggedValue(ProfileConstants.TAGGED_VALUE_NAME_CHARACTERIZABLE_CONTAINER, ProfileConstants.STEREOTYPE_NAME_CHARACTERIZABLE) as CharacteristicContainer;
				characteristicContainer.ownedCharacteristics.clear
			]
		]
		runComparingTransformationTest("contactSMSManager", modifier, "expectedEmptyRolesInScenarioBehavior.xmi");
	}
	
	@Test
	@Category(ResultFailImmediatelyRoles)
	def testEmptyRolesInResourceContainer() {
		// remove all roles from resource containers
		val ModelModifier modifier = [um, sys, am, ctc | 
			for (val resourceContainers = new LinkedList(am.targetResourceEnvironment_Allocation.resourceContainer_ResourceEnvironment); !resourceContainers.isEmpty; ) {
				val rc = resourceContainers.pop
				resourceContainers.addAll(rc.nestedResourceContainers__ResourceContainer)
				if (rc.isStereotypeApplied(ProfileConstants.STEREOTYPE_NAME_CHARACTERIZABLE)) {
					val characteristicContainer = rc.getTaggedValue(ProfileConstants.TAGGED_VALUE_NAME_CHARACTERIZABLE_CONTAINER, ProfileConstants.STEREOTYPE_NAME_CHARACTERIZABLE) as CharacteristicContainer;
					characteristicContainer.ownedCharacteristics.clear
				}
			}
		]
		runComparingTransformationTest("contactSMSManager", modifier, "expectedEmptyRolesInResourceContainer.xmi");
	}
	
	@Test
	@Category(ResultFailImmediatelyCreate)
	def testAccessRightsMismatchAfterDataCreationWithExplicitCharacteristics() {
		// 1: remove all creation default characteristics for Contact data
		// 2: set mismatching right during data creation explicitly
		val ModelModifier modifier = [um, sys, am, ctc |
			val dataSpecification = um.dataSpecification
			val contactCreationEffects = dataSpecification.processingEffects.filter(DataCreationProcessingEffect).filter[toDataType instanceof NamedElement].filter[(toDataType as NamedElement).entityName.contains("Contact")]
			val contactCreationCharacteristics = contactCreationEffects.flatMap[characteristicChanges].flatMap[characteristicSpecifications].filter(DirectCharacteristic).map[characteristic].filter(EnumCharacteristic)
			val mismatchingCharacteristic = EcoreUtil.copy(contactCreationCharacteristics.findFirst[true])
			mismatchingCharacteristic.literals.removeIf([entityName.contains("User")])
			contactCreationEffects.forEach[characteristicChanges.clear]
			dataSpecification.dataProcessingContainers.flatMap[operations].filter(CreateDataOperation).filter[resultingData.type instanceof NamedElement].filter[(resultingData.type as NamedElement).entityName.contains("Contact")].forEach[initialCharacteristics.add(EcoreUtil.copy(mismatchingCharacteristic))]
		]
		runComparingTransformationTest("contactSMSManager", modifier, "expectedAccessRightsMismatchAfterDataCreationWithExplicitCharacteristics.xmi");
	}
	
	@Test
	@Category(ResultFailImmediatelyCreate)
	def testAccessRightsMismatchAfterDataCreationWithDefaultCharacteristics() {
		// remove user access rights from data creation effect specification
		val ModelModifier modifier = [um, sys, am, ctc |
			um.dataSpecification.processingEffects.filter(DataCreationProcessingEffect).filter[toDataType instanceof NamedElement].filter[(toDataType as NamedElement).entityName.contains("Contact")].forEach[characteristicChanges.forEach [
				characteristicSpecifications.filter(DirectCharacteristic).map[characteristic].filter(EnumCharacteristic).forEach[literals.removeIf([l | l.entityName.contains("User")])]
			]]
		]
		runComparingTransformationTest("contactSMSManager", modifier, "expectedAccessRightsMismatchAfterDataCreationWithDefaultCharacteristics.xmi");
	}
	
	@Test
	@Category(ResultFailImmediatelyCreate)
	def testEmptyAccessRightsAfterDataCreation() {
		// remove all access rights from data creation effect specification
		val ModelModifier modifier = [um, sys, am, ctc | 
			um.dataSpecification.processingEffects.filter(DataCreationProcessingEffect).forEach[characteristicChanges.clear]
		]
		runComparingTransformationTest("contactSMSManager", modifier, "expectedEmptyAccessRightsAfterDataCreation.xmi");
	}
	
	@Test
	@Category(ResultFailImmediatelyLoad)
	def testAccessRightsMismatchAfterLoadData() {
		// remove user role from user identifier store default characteristics
		val ModelModifier modifier = [um, sys, am, ctc |
			val accessRightsCharacteristicType = ctc.characteristicTypes.findFirst[entityName.contains("AccessRights")]
			val dataSpecification = um.dataSpecification
			val characteristics = dataSpecification.storeCharacteristicContainers.flatMap[characteristics].findFirst[store.dataType instanceof PrimitiveDataType]
			val characteristic = characteristics.ownedCharacteristics.filter(EnumCharacteristic).findFirst[characteristicType == accessRightsCharacteristicType]
			characteristic.literals.removeIf([entityName.contains("User")])
		]
		runComparingTransformationTest("distanceTracker", modifier, "expectedAccessRightsMismatchAfterLoadData.xmi");
	}
	
	@Test
	@Category(ResultFailImmediatelyLoad)
	def testAccessRightsMismatchAfterEmptyLoadData() {
		// remove all roles from user identifier store default characteristics
		val ModelModifier modifier = [um, sys, am, ctc |
			val accessRightsCharacteristicType = ctc.characteristicTypes.findFirst[entityName.contains("AccessRights")]
			val dataSpecification = um.dataSpecification
			val characteristics = dataSpecification.storeCharacteristicContainers.flatMap[characteristics].findFirst[store.dataType instanceof PrimitiveDataType]
			val characteristic = characteristics.ownedCharacteristics.filter(EnumCharacteristic).findFirst[characteristicType == accessRightsCharacteristicType]
			characteristic.literals.clear()
		]
		runComparingTransformationTest("distanceTracker", modifier, "expectedAccessRightsMismatchAfterEmptyLoadData.xmi");
	}
	
	@Test
	@Category(ResultFailImmediatelyLoad)
	def testAccessRightsMismatchAfterLoadAllData() {
		// remove contact role from contacts store default characteristics
		val ModelModifier modifier = [um, sys, am, ctc |
			val accessRightsCharacteristicType = ctc.characteristicTypes.findFirst[entityName.contains("AccessRights")]
			val dataSpecification = um.dataSpecification
			val characteristics = dataSpecification.storeCharacteristicContainers.flatMap[characteristics].filter[store.dataType instanceof CompositeDataType].findFirst[(store.dataType as CompositeDataType).entityName.equals("Contact")]
			val characteristic = characteristics.ownedCharacteristics.filter(EnumCharacteristic).findFirst[characteristicType == accessRightsCharacteristicType]
			characteristic.literals.removeIf([entityName.contains("Contact")])
		]
		runComparingTransformationTest("contactSMSManager", modifier, "expectedAccessRightsMismatchAfterLoadAllData.xmi");
	}
	
	@Test
	@Category(ResultFailImmediatelyLoad)
	def testAccessRightsMismatchAfterEmptyLoadAllData() {
		// remove all roles from contacts store default characteristics
		val ModelModifier modifier = [um, sys, am, ctc |
			val accessRightsCharacteristicType = ctc.characteristicTypes.findFirst[entityName.contains("AccessRights")]
			val dataSpecification = um.dataSpecification
			val characteristics = dataSpecification.storeCharacteristicContainers.flatMap[characteristics].filter[store.dataType instanceof CompositeDataType].findFirst[(store.dataType as CompositeDataType).entityName.equals("Contact")]
			val characteristic = characteristics.ownedCharacteristics.filter(EnumCharacteristic).findFirst[characteristicType == accessRightsCharacteristicType]
			characteristic.literals.clear()
		]
		runComparingTransformationTest("contactSMSManager", modifier, "expectedAccessRightsMismatchAfterEmptyLoadAllData.xmi");
	}
	
	@Test
	@Category(ResultFailDataTransfer)
	def testAccessRightsMismatchAfterReturn() {
		// remove user role from data creation effect of confirmation
		val ModelModifier modifier = [um, sys, am, ctc |
			val accessRightsCharacteristicType = ctc.characteristicTypes.findFirst[entityName.contains("AccessRights")]
			val dataSpecification = um.dataSpecification
			val dataCreationEffect = dataSpecification.processingEffects.filter(DataCreationProcessingEffect).findFirst[true]
			dataCreationEffect.characteristicChanges.flatMap[characteristicSpecifications].filter(DirectCharacteristic).map[characteristic].filter[characteristicType == accessRightsCharacteristicType].filter(EnumCharacteristic).forEach[literals.removeIf([entityName.equals("User")])]
		]
		runComparingTransformationTest("distanceTracker", modifier, "expectedAccessRightsMismatchAfterReturn.xmi");
	}
	
	@Test
	@Category(ResultFailDataTransfer)
	def testAccessRightsMismatchAfterSend() {
		// remove contact role from data creation effect of contact
		val ModelModifier modifier = [um, sys, am, ctc |
			val accessRightsCharacteristicType = ctc.characteristicTypes.findFirst[entityName.contains("AccessRights")]
			val dataSpecification = um.dataSpecification
			val dataCreationEffect = dataSpecification.processingEffects.filter(DataCreationProcessingEffect).filter[toDataType instanceof CompositeDataType].findFirst[(toDataType as CompositeDataType).entityName.equals("Contact")]
			dataCreationEffect.characteristicChanges.flatMap[characteristicSpecifications].filter(DirectCharacteristic).map[characteristic].filter[characteristicType == accessRightsCharacteristicType].filter(EnumCharacteristic).forEach[literals.removeIf([entityName.equals("Contacts")])]
		]
		runComparingTransformationTest("contactSMSManager", modifier, "expectedAccessRightsMismatchAfterSend.xmi");
	}
	
	@Test
	@Category(ResultFailDataProcessing)
	def testAccessRightsMismatchAfterJoin() {
		// remove processing effect of declassification operation
		val ModelModifier modifier = [um, sys, am, ctc |
			val dataSpecification = um.dataSpecification
			val dataprocessingEffect = dataSpecification.processingEffects.filter(OperationTypeDataProcessingEffect).findFirst[entityName.contains("declassify")]
			dataprocessingEffect.characteristicChanges.clear
		]
		runComparingTransformationTest("distanceTracker", modifier, "expectedAccessRightsMismatchAfterJoin.xmi");
	}
	
	@Test
	@Category(ResultFailDataProcessing)
	def testAccessRightsMismatchAfterUnion() {
		// 1. remove contact role from data creation effect of contact
		// 2. ContactApp_listContacts: Add CreateDataOperation for contact
		// 3. ContactApp_listContacts: Add UnionDataOperation combining created and loaded contacts
		// 4. ContactApp_listContacts: Return merged data
		val ModelModifier modifier = [um, sys, am, ctc |
			// Remove contact role
			val accessRightsCharacteristicType = ctc.characteristicTypes.findFirst[entityName.contains("AccessRights")]
			val dataSpecification = um.dataSpecification
			val dataCreationEffect = dataSpecification.processingEffects.filter(DataCreationProcessingEffect).filter[toDataType instanceof CompositeDataType].findFirst[(toDataType as CompositeDataType).entityName.equals("Contact")]
			dataCreationEffect.characteristicChanges.flatMap[characteristicSpecifications].filter(DirectCharacteristic).map[characteristic].filter[characteristicType == accessRightsCharacteristicType].filter(EnumCharacteristic).forEach[literals.removeIf([entityName.equals("Contacts")])]
			
			// DataProcessingContainer ContactApp_listContacts
			val dpc = dataSpecification.dataProcessingContainers.findFirst[entityName == "ContactApp_listContacts"]
			
			// Contact DataType
			val contactListData = dpc.operations.filter(LoadAllDataOperation).map[resultingData].findFirst[true]
			val contactDataType = (contactListData.type as CollectionDataType).innerType_CollectionDataType
			
			// CreateDataOperation
			val createOperation = ProcessingFactory.eINSTANCE.createCreateDataOperation
			createOperation.entityName = "ContactApp_listContacts_createContact"
			createOperation.id = createOperation.entityName
			val createdContactData = DataFactory.eINSTANCE.createOriginalData
			createOperation.resultingData = createdContactData
			createdContactData.entityName = "ContactApp_listContacts_createContact_Contact"
			createdContactData.id = createdContactData.entityName
			createdContactData.originalType = contactDataType
			dpc.operations += createOperation
			
			// UnionDataOperation
			val unionOperation = ProcessingFactory.eINSTANCE.createUnionDataOperation
			unionOperation.entityName = "ContactApp_listContacts_combineContacts"
			unionOperation.id = unionOperation.entityName
			unionOperation.consumedData += createdContactData
			unionOperation.consumedData += contactListData
			val mergedData = DataFactory.eINSTANCE.createDerivedData
			unionOperation.resultingData = mergedData
			mergedData.entityName = "ContactApp_listContacts_combineContacts_ContactList"
			mergedData.id = mergedData.entityName
			mergedData.resultingDataType = contactListData.type
			mergedData.sources += unionOperation.consumedData
			dpc.operations += unionOperation
			
			// Adjust ReturnDataOperation
			val returnOperation = dpc.operations.filter(ReturnDataOperation).findFirst[true]
			returnOperation.consumedData = mergedData
			
		]
		runComparingTransformationTest("contactSMSManager", modifier, "expectedAccessRightsMismatchAfterUnion.xmi");
	}
	
	@Test
	@Category(ResultFailDataProcessing)
	def testAccessRightsMismatchAfterDataProcessingEffectOperation() {
		// remove SMS role from processing effect
		val ModelModifier modifier = [um, sys, am, ctc |
			val accessRightsCharacteristicType = ctc.characteristicTypes.findFirst[entityName.contains("AccessRights")]
			val dataSpecification = um.dataSpecification
			val dataProcessingEffect = dataSpecification.processingEffects.filter(OperationTypeDataProcessingEffect).findFirst[true]
			dataProcessingEffect.characteristicChanges.flatMap[characteristicSpecifications].filter(DirectCharacteristic).map[characteristic].filter[characteristicType == accessRightsCharacteristicType].filter(EnumCharacteristic).forEach[literals.removeIf([entityName.equals("SMS")])]
		]
		runComparingTransformationTest("contactSMSManager", modifier, "expectedAccessRightsMismatchAfterDataProcessingEffectOperation.xmi");
	}
	
	protected def runComparingTransformationTest(String folderName, ModelModifier mm, String expectedFileName) {
		val ModelModifier mm2 = [um, sys, am, ctc | 
			mm.modify(um, sys, am, ctc)
//			val r = um.eResource.resourceSet.createResource(createRelativeURI("models/" + folderName + "/" + expectedFileName + ".src"))
//			r.contents.clear
//			r.contents += um.dataSpecification
//			r.save(null)
		]
		runComparingTransformationTest(folderName, Optional.of(mm2), Optional.of(expectedFileName), Optional.empty);
	}
	
	protected def getDataSpecification(UsageModel um) {
		val scenarioBehavior = um.usageScenario_UsageModel.findFirst[true].scenarioBehaviour_UsageScenario
		val characteristicContainer = scenarioBehavior.getTaggedValue(ProfileConstants.TAGGED_VALUE_NAME_CHARACTERIZABLE_CONTAINER, ProfileConstants.STEREOTYPE_NAME_CHARACTERIZABLE);
		val rootElement = EcoreUtil.getRootContainer(characteristicContainer)
		rootElement as DataSpecification
	}
}