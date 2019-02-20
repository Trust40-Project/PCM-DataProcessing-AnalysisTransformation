package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.basic.impl

import java.util.ArrayList
import java.util.Collections
import java.util.Map
import org.eclipse.emf.ecore.EObject
import org.palladiosimulator.mdsdprofiles.api.StereotypeAPI
import org.palladiosimulator.pcm.allocation.Allocation
import org.palladiosimulator.pcm.core.composition.AssemblyContext
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.basic.ITransformator
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics.IQueryExecutor
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics.IReturnValueAssignmentGeneratorRegistry
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics.impl.QueryExecutorDelegator
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.dto.IdentifierInstance
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.dto.SEFFInstance
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.naming.ICachingUniqueNameProvider
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.util.EMFUtils
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.util.Hash
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.characteristics.Characteristic
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.characteristics.CharacteristicContainer
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.characteristics.CharacteristicType
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.characteristics.CharacteristicTypeContainer
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.characteristics.EnumCharacteristic
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.characteristics.EnumCharacteristicLiteral
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.characteristics.EnumCharacteristicType
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.characteristics.Enumeration
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.data.Data
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.processing.DataOperation
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.processing.ReturnDataOperation
import org.palladiosimulator.pcm.dataprocessing.profile.api.ProfileConstants
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.Caller
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.LogicTerm
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.Operation
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.PrologmodelFactory
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.ValueSetType
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.VariableAssignment
import org.palladiosimulator.pcm.repository.DataType
import org.palladiosimulator.pcm.system.System
import org.palladiosimulator.pcm.usagemodel.ScenarioBehaviour
import org.palladiosimulator.pcm.usagemodel.UsageModel

import static org.palladiosimulator.pcm.dataprocessing.analysis.transformation.dto.IdentifierInstance.*

class PCM2DFSystemModelTransformation implements ITransformator, TransformationFacilities {
	
	static val factory = PrologmodelFactory.eINSTANCE
	val extension ICachingUniqueNameProvider uniqueNameProvider
	val IReturnValueAssignmentGeneratorRegistry returnValueAssignmentGeneratorRegistry;
	val IQueryExecutor queryExecutor = createQueryExecutor()
	var Allocation pcmAllocationModel
	var CharacteristicTypeContainer pcmCharacteristicTypeContainer
	
	new(IReturnValueAssignmentGeneratorRegistry returnValueAssignmentGeneratorRegistry, ICachingUniqueNameProvider nameProvider) {
		this.returnValueAssignmentGeneratorRegistry = returnValueAssignmentGeneratorRegistry
		this.uniqueNameProvider = nameProvider
	}
	
	override transform(UsageModel pcmUsageModel, System pcmSystem, Allocation pcmAllocationModel, CharacteristicTypeContainer pcmCharacteristicTypeContainer) {
		this.pcmAllocationModel = pcmAllocationModel
		this.pcmCharacteristicTypeContainer = pcmCharacteristicTypeContainer
		system.name = pcmSystem.entityName
		system.types += pcmCharacteristicTypeContainer.characteristicTypes.map[valueType]
		system.attributes += pcmCharacteristicTypeContainer.characteristicTypes.map[attribute]
		system.properties += pcmCharacteristicTypeContainer.characteristicTypes.map[property]
		system.operations += BehaviorTransformator.findAllSEFFs(pcmSystem).map[getSEFFOperation]
		system.systemusages += pcmUsageModel.usageScenario_UsageModel.map[scenarioBehaviour_UsageScenario].map[getSystemUsage]
		system.datatypes.forEach[dt | dt.attributes += system.attributes] // we might want to optimise this later
		
		val idToObject = uniqueNameProvider.cache.inverse
		val idDump = idToObject.keySet.sort.map[k | '''«k» -> «idToObject.get(k)»'''].join("\n")
		print(idDump)
		
		system
	}
	
	// TRANSFORMATION: n/a -> System
	override create sys: factory.createSystem getSystem() {
		// intentionally left blank
	}
	
	// TRANSFORMATION: CharacteristicType -> ValueType
	protected def dispatch ValueSetType getValueType(CharacteristicType characteristicType) {
		throw new IllegalArgumentException("We only support " + EnumCharacteristicType.simpleName + " for now.")
	}
	
	protected def dispatch ValueSetType getValueType(EnumCharacteristicType characteristicType) {
		characteristicType.enum.getValueTypeByRange
	}
	
	protected def create valueSetType: factory.createValueSetType getValueTypeByRange(Enumeration enumDefinition) {
		valueSetType.name = enumDefinition.uniqueName
		valueSetType.values += enumDefinition.literals.map[getValue]
	}
	
	// TRANSFORMATION: CharacteristicType -> Attribute
	protected def create attr: factory.createAttribute getAttribute(CharacteristicType characteristicType) {
		attr.name = characteristicType.uniqueName
		attr.type = characteristicType.valueType
	}
	
	// TRANSFORMATION: Literal -> value
	protected def create value: factory.createValue getValue(EnumCharacteristicLiteral literal) {
		value.name = literal.uniqueName
	}
	
	// TRANSFORMATION: CharacteristicType -> Property
	protected def create prop: factory.createProperty getProperty(CharacteristicType characteristicType) {
		prop.name = characteristicType.uniqueName
		prop.type = characteristicType.valueType
	}
		
	// TRANSFORMATION: ScenarioBehavior -> SystemUsage
	protected def create sysUsage: factory.createSystemUsage getSystemUsage(ScenarioBehaviour scenarioBehavior) {
		sysUsage.name = scenarioBehavior.uniqueName
		
		val delegateOperation = scenarioBehavior.systemUsageDataOperation
		system.operations += delegateOperation
		sysUsage.calls += sysUsage.getOperationCall(delegateOperation)
		
		// we just do one call to the operation and do not pass any information
	}
	
	// TRANSFORMATION: ScenarioBehaviour -> Operation
	protected def create sysUsageDataOp: factory.createOperation getSystemUsageDataOperation(ScenarioBehaviour scenarioBehavior) {
		sysUsageDataOp.name = scenarioBehavior.uniqueName + "_dataOp"
		
		val transformator = new UsageModelBehaviorTransformator(this)
		transformator.transformBehavior(sysUsageDataOp, createInstance(null, scenarioBehavior))
		
		// copy properties of processing node to operation
		scenarioBehavior.copyCharacteristicsTo(sysUsageDataOp)
	}
	
	// TRANSFORMATION: SEFFInstance -> Operation
	override create op: factory.createOperation getSEFFOperation(SEFFInstance seffInstance) {
		op.name = seffInstance.uniqueName
		
		val transformator = new SEFFBehaviorTransformator(this)
		transformator.transformBehavior(op, seffInstance)
		
		// copy properties of processing node to operation
		val assemblyContext = seffInstance.identifier.get
		assemblyContext.copyCharacteristicsTo(op)
	}
	
	// TRANSFORMATION: SEFFInstance, DataOperation -> Operation
	override create op: factory.createOperation getOperation(IdentifierInstance<DataOperation, AssemblyContext> dataOpInstance) {
		op.name = dataOpInstance.uniqueName
		
		// we never have input parameters
		// usage of state variables depends on concrete DataOperation (not handled here)
		// we have to determine calls later
		
		// create return variables in current operation (containment)
		var outgoingData = dataOpInstance.outgoingData
		op.returnValues += outgoingData.map[getReturnVariable(dataOpInstance)]
		
		// we assume that properties have been copied or will be copied
	}
	
	override getOperation(IdentifierInstance<DataOperation, AssemblyContext> dataOpInstance, EObject propertySource) {
		val op = dataOpInstance.operation
		propertySource.copyCharacteristicsTo(op)
		op
	}

	// TRANSFORMATION: SEFFInstance, Operation/Operation -> OperationCall
	override create opCall: factory.createOperationCall getOperationCall(Caller from, Operation to) {
		opCall.caller = from
		opCall.callee = to
		opCall.name = 'opCall_' + Hash.init(from.name).add(to.name).hash
	}

	// TRANSFORMATION: Data -> Variable
	override getStateVariable(Data data, IdentifierInstance<?, ?> instance) {
		data.getVariable(VariablePurpose.STATE, instance)
	}
	
	protected def getParameterVariable(Data data, IdentifierInstance<?, ?> instance) {
		data.getVariable(VariablePurpose.PARAMETER, instance)
	}
	
	override getReturnVariable(Data data, IdentifierInstance<?, ?> instance) {
		data.getVariable(VariablePurpose.RETURN, instance)
	}
	
	protected def create variable: factory.createVariable getVariable(Data data, VariablePurpose purpose, IdentifierInstance<?, ?> entityInstance) {
		variable.name = '''«data.entityName»_«purpose»_«Hash.init(entityInstance.uniqueName).add(data.uniqueName).hash»'''
		variable.datatype = data.type.dataType
	}
	
	private enum VariablePurpose {
		PARAMETER,
		STATE,
		RETURN
	}

	// TRANSFORMATION: DataType -> DataType
	protected def getDataType(DataType dataType) {
		getDataTypeInternal(new DataTypeWrapper(dataType))
	}
	
	protected def create dt: factory.createDataType getDataTypeInternal(DataType dataType) {
		dt.name = dataType.uniqueName
		system.datatypes += dt
	}
	
	// Helpers
	
	override getResourceContainer(AssemblyContext ac) {
		pcmAllocationModel.allocationContexts_Allocation.findFirst[a | a.assemblyContext_AllocationContext === ac].resourceContainer_AllocationContext
	}
	
	protected def copyCharacteristicsTo(AssemblyContext ac, Operation op) {
		val resourceContainer = ac.resourceContainer
		resourceContainer.copyCharacteristicsTo(op)
	}
	
	protected def copyCharacteristicsTo(EObject characteristicHolder, Operation op) {
		if (StereotypeAPI.hasAppliedStereotype(#{characteristicHolder}, ProfileConstants.STEREOTYPE_NAME_CHARACTERIZABLE)) {
			val characteristicContainer = EMFUtils.getTaggedValue(characteristicHolder, ProfileConstants.TAGGED_VALUE_NAME_CHARACTERIZABLE_CONTAINER, ProfileConstants.STEREOTYPE_NAME_CHARACTERIZABLE, CharacteristicContainer)
			for (characteristic : characteristicContainer.ownedCharacteristics) {
				val propDef = factory.createPropertyDefinition
				propDef.property = characteristic.characteristicType.property
				propDef.presentValues += characteristic.values
				op.propertyDefinitions += propDef
			}
		}
	}
	
	protected def dispatch getValues(EnumCharacteristic characteristic) {
		characteristic.literals.map[getValue]
	}
	
	protected def dispatch getValues(Characteristic characteristic) {
		throw new IllegalArgumentException("Unable to transform characteristic " + characteristic.class.name)
	}
	
	override createReturnValueAssignments(IdentifierInstance<DataOperation, AssemblyContext> opInstance, Map<Data, LogicTerm> availableData) {
		val returnVariables = newImmutableMap(opInstance.outgoingData.map[data | data -> data.getReturnVariable(opInstance)])
		
		val result = new ArrayList<VariableAssignment>()
		for (generator : returnValueAssignmentGeneratorRegistry.generators) {
			result += generator.generateAssignments(queryExecutor, opInstance.identifier, opInstance.entity, availableData, returnVariables)
		}
		result
	}
	
	protected def getOutgoingData(IdentifierInstance<DataOperation, AssemblyContext> dataOpInstance) {
		dataOpInstance.entity.outgoingData + #[dataOpInstance.entity].filter(ReturnDataOperation).flatMap[incomingData]
	}

	protected def createQueryExecutor() {
		return new QueryExecutorDelegator(
			[values],
			[attribute],
			[ct | Collections.unmodifiableCollection(ct.valueType.values)],
			[Collections.unmodifiableCollection(pcmCharacteristicTypeContainer.characteristicTypes)]
		);
	}
}