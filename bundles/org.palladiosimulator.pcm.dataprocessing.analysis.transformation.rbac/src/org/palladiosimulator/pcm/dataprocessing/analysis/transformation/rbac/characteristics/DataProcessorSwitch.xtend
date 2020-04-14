package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.rbac.characteristics

import java.util.ArrayList
import java.util.List
import java.util.Map
import java.util.Optional
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EcoreUtil
import org.palladiosimulator.pcm.core.composition.AssemblyContext
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics.IQueryExecutor
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.data.Data
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.processing.ManyToOneDataOperation
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.processing.TransformDataOperation
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.processing.util.ProcessingSwitch
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.Attribute
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.DefaultStateRef
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.LogicTerm
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.ParameterRef
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.PrologmodelFactory
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.PropertyRef
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.ReturnValueRef
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.StateRef
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.Variable
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.VariableAssignment
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.Value

class DataProcessorSwitch extends ProcessingSwitch<List<VariableAssignment>> {

	static extension val PrologmodelFactory factory = PrologmodelFactory.eINSTANCE
	val IQueryExecutor queryExecutor
	val Map<Data, LogicTerm> availableData
	val Map<Data, Variable> returnVariables
	val String characteristicNameAccessRights

	new(IQueryExecutor queryExecutor, Optional<AssemblyContext> ac, Map<Data, LogicTerm> availableData,
		Map<Data, Variable> returnVariables, String characteristicNameRoles, String characteristicNameAccessRights) {
		this.queryExecutor = queryExecutor
		this.availableData = availableData
		this.returnVariables = returnVariables
		this.characteristicNameAccessRights = characteristicNameAccessRights
	}
	
	/**
	 * When joining data or creating the union, the set of access rights is the
	 * intersection of the access rights of the inputs. An access right is only
	 * set, if the particular access right is set on all incoming data. 
	 */
	override caseManyToOneDataOperation(ManyToOneDataOperation op) {
		val relevantCharacteristicType = queryExecutor.characteristicTypes.findFirst[ct | ct.entityName == characteristicNameAccessRights]
		val values = queryExecutor.getValues(relevantCharacteristicType)

		val result = new ArrayList<VariableAssignment>()

		for (returnVariable : returnVariables.entrySet) { // should be exactly one
			val attribute = queryExecutor.getAttribute(relevantCharacteristicType)
			//TODO try to avoid generating assignments for single values
			for (value : values) {
				val assignment = createVariableAssignment
				assignment.variable = returnVariable.value
				assignment.attribute = attribute
				assignment.value = value
				val term = createAnd
				for (inputTerm : op.consumedData.map[d | availableData.get(d)]) {
					val inputTermCopy = EcoreUtil.copy(inputTerm)
					inputTermCopy.setAttributeAndValue(attribute, value)
					term.operands += inputTermCopy
				}
				assignment.term = term
				result += assignment
			}
		}
		
		result
	}
	
	override caseTransformDataOperation(TransformDataOperation op) {
		// special handling might be useful to reflect changing privacy levels depending on operation and data
		op.defaultCase
	}

	override defaultCase(EObject obj) {
		#[]
	}
	
	protected static def dispatch setAttributeAndValue(ReturnValueRef ref, Attribute attribute, Value value) {
		ref.attribute = attribute
		ref.value = value
	}
	
	protected static def dispatch setAttributeAndValue(StateRef ref, Attribute attribute, Value value) {
		ref.attribute = attribute
		ref.value = value
	}
	
	protected static def dispatch setAttributeAndValue(DefaultStateRef ref, Attribute attribute, Value value) {
		ref.attribute = attribute
		ref.value = value
	}
	
	protected static def dispatch setAttributeAndValue(ParameterRef ref, Attribute attribute, Value value) {
		ref.attribute = attribute
		ref.value = value
	}
	
	protected static def dispatch setAttributeAndValue(PropertyRef ref, Attribute attribute, Value value) {
		// do not set attribute
		ref.value = value
	}
	
	protected static def dispatch setAttributeAndValue(LogicTerm term, Attribute attribute, Value value) {
		// do nothing
	}
	
}
