package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics.impl

import com.google.common.base.Supplier
import java.util.ArrayList
import java.util.Map
import org.eclipse.emf.ecore.util.EcoreUtil
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics.IQueryExecutor
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.characteristics.Characteristic
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.characteristics.CharacteristicType
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.data.Data
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.effectspecification.CharacteristicSpecification
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.effectspecification.DirectCharacteristic
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.effectspecification.MinStaticCharacteristic
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.processing.CharacteristicChangeOperation
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.processing.DataOperation
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.Attribute
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.DefaultStateRef
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.LogicTerm
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.ParameterRef
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.PrologmodelFactory
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.ReturnValueRef
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.StateRef
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.Variable
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.VariableAssignment

import static org.apache.commons.lang3.Validate.*

class AssignmentsGeneratorUtils {
	
	static extension val PrologmodelFactory factory = PrologmodelFactory.eINSTANCE
	
	private new() {
		// do not allow instantiating this class
	}
	
	static def dispatch createChangeAssignmentsBySpecification(DirectCharacteristic spec, Variable returnVariable, IQueryExecutor queryExecutor, DataOperation dataOperation, Map<Data, LogicTerm> availableData) {
		val changeOperation = spec.characteristicChange.changeOperation
		val sourceCharacteristic = spec.characteristic
		returnVariable.createDirectChangeAssignments(changeOperation, queryExecutor, sourceCharacteristic, sourceCharacteristic.characteristicType)
	}
	
	static def dispatch createChangeAssignmentsBySpecification(MinStaticCharacteristic spec, Variable returnVariable, IQueryExecutor queryExecutor, DataOperation dataOperation, Map<Data, LogicTerm> availableData) {
		val changeOperation = spec.characteristicChange.changeOperation
		val minValue = spec.staticMinValue
		returnVariable.createMinStaticChangeAssignments(changeOperation, queryExecutor, minValue, minValue.characteristicType, dataOperation, availableData)
	}
	
	static def dispatch createChangeAssignmentsBySpecification(CharacteristicSpecification spec, Variable returnVariable, IQueryExecutor queryExecutor, DataOperation dataOperation, Map<Data, LogicTerm> availableData) {
		#[]
	}
	
	
	static def createDirectChangeAssignments(Variable variable, CharacteristicChangeOperation changeOperation, IQueryExecutor queryExecutor, Characteristic sourceCharacteristic, CharacteristicType targetCharacteristicType) {
		val result = new ArrayList<VariableAssignment>()
		
		val sourceAttribute = queryExecutor.getAttribute(sourceCharacteristic.characteristicType)
		notNull(sourceAttribute)
		val targetAttribute = queryExecutor.getAttribute(targetCharacteristicType)
		notNull(targetAttribute)
		
		// copy has to take place before

		// replace: set all values related to the characteristic to false
		if (changeOperation === CharacteristicChangeOperation.REPLACE) {
			
			val resetAssignment = createVariableAssignment
			resetAssignment.variable = variable
			resetAssignment.attribute = targetAttribute
			resetAssignment.term = createFalse
			result += resetAssignment
		}
		
		// always: set values mentioned in the operation
		val Supplier<LogicTerm> termProvider = if (changeOperation === CharacteristicChangeOperation.REMOVE) [createFalse] else [createTrue]
		val values = queryExecutor.getValues(sourceCharacteristic)
		notNull(values)
		for (value : values) {
			val changeAssignment = createVariableAssignment
			changeAssignment.variable = variable
			changeAssignment.attribute = targetAttribute
			changeAssignment.value = value
			changeAssignment.term = termProvider.get
			result += changeAssignment
		}

		result
	}
	
	static def createMinStaticChangeAssignments(Variable variable, CharacteristicChangeOperation changeOperation, extension IQueryExecutor queryExecutor, Characteristic sourceCharacteristic, CharacteristicType targetCharacteristicType, DataOperation dataOperation, Map<Data, LogicTerm> availableData) {
		val sourceAttribute = queryExecutor.getAttribute(sourceCharacteristic.characteristicType)
		notNull(sourceAttribute)
		val targetAttribute = queryExecutor.getAttribute(targetCharacteristicType)
		notNull(targetAttribute)
		validState(sourceCharacteristic.values.size == 1)
		val minStaticValue = sourceCharacteristic.values.iterator.next
		
		val minAssignment = createVariableAssignment
		minAssignment.variable = variable
		minAssignment.attribute = targetAttribute
		val minTerm = createMinStatic
		minTerm.value = minStaticValue
		minTerm.operands.addAll(dataOperation.incomingData.map[d | availableData.get(d)].map[d | d.copy(targetAttribute)])
		minAssignment.term = minTerm

		#[minAssignment]
	}
	
	static def createAssignments(Variable variable, Iterable<Characteristic> characteristics, extension IQueryExecutor queryExecutor) {
		val result = new ArrayList<VariableAssignment>()
		
		val falseAssignment = createVariableAssignment
		falseAssignment.variable = variable
		falseAssignment.term = createFalse
		result += falseAssignment
		
		for (characteristic : characteristics) {
			val attribute = characteristic.characteristicType.attribute
			for (value : characteristic.values) {
				val changeAssignment = createVariableAssignment
				changeAssignment.variable = variable
				changeAssignment.attribute = attribute
				changeAssignment.value = value
				changeAssignment.term = createTrue
				result += changeAssignment
			}
		}
		result
	}
	
	static def createCopyAssignment(Variable destination, LogicTerm assignment) {
		notNull(destination)
		notNull(assignment)
		val copyAssignment = createVariableAssignment
		copyAssignment.variable = destination
		copyAssignment.term = assignment
		copyAssignment
	}
	
	static def LogicTerm copy(LogicTerm term, Attribute attribute) {
		val termCopy = EcoreUtil.copy(term)
		termCopy.attributeOnTerm = attribute
	}
	
	static def dispatch LogicTerm setAttributeOnTerm(DefaultStateRef term, Attribute attribute) {
		term.attribute = attribute
		term
	}
	
	static def dispatch LogicTerm setAttributeOnTerm(ParameterRef term, Attribute attribute) {
		term.attribute = attribute
		term
	}
	
	static def dispatch LogicTerm setAttributeOnTerm(ReturnValueRef term, Attribute attribute) {
		term.attribute = attribute
		term
	}
	
	static def dispatch LogicTerm setAttributeOnTerm(StateRef term, Attribute attribute) {
		term.attribute = attribute
		term
	}
}