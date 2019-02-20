package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics.impl

import java.util.ArrayList
import java.util.Map
import java.util.Optional
import org.osgi.service.component.annotations.Component
import org.palladiosimulator.mdsdprofiles.api.StereotypeAPI
import org.palladiosimulator.pcm.core.composition.AssemblyContext
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics.IQueryExecutor
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics.IReturnValueAssignmentGenerator
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.util.EMFUtils
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.characteristics.StoreCharacteristicContainer
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.data.Data
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.processing.CharacteristicChangingDataOperation
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.processing.CreateDataOperation
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.processing.DataOperation
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.processing.LoadDataOperation
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.processing.ReturnDataOperation
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.processing.TransformDataOperation
import org.palladiosimulator.pcm.dataprocessing.profile.api.ProfileConstants
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.LogicTerm
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.Variable
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.VariableAssignment

import static org.apache.commons.lang3.Validate.*
import static extension org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics.impl.AssignmentsGeneratorUtils.*

@Component
class DefaultReturnValueAssignmentGenerator implements IReturnValueAssignmentGenerator {
	
	override getProducedType() {
		ProducedAssignmentType.DEFAULTS
	}
	
	override generateAssignments(IQueryExecutor queryExecutor, Optional<AssemblyContext> ac, DataOperation dataOperation, Map<Data, LogicTerm> availableData, Map<Data, Variable> returnVariables) {
		notNull(queryExecutor)
		notNull(dataOperation)
		notNull(availableData)
		notNull(returnVariables)
		dataOperation.generateAssignmentsInternal(queryExecutor, ac, availableData, returnVariables)
	}
	
	protected def dispatch generateAssignmentsInternal(DataOperation dataOperation, IQueryExecutor queryExecutor, Optional<AssemblyContext> ac, Map<Data, LogicTerm> availableData, Map<Data, Variable> returnVariables) {
		// default case: generate single assignments for each operation
		val result = new ArrayList<VariableAssignment>()
		for (data : returnVariables.keySet.sortBy[id]) {
			val returnVariable = data -> returnVariables.get(data)
			notNull(returnVariable.key)
			notNull(returnVariable.value)
			result += dataOperation.generate(returnVariable, availableData, queryExecutor, ac)
		}
		result
	}
	
	protected def dispatch generateAssignmentsInternal(TransformDataOperation dataOperation, IQueryExecutor queryExecutor, Optional<AssemblyContext> ac, Map<Data, LogicTerm> availableData, Map<Data, Variable> returnVariables) {
		val returnVariable = returnVariables.get(dataOperation.output)
		val logicTerm = availableData.get(dataOperation.input)
		#[createCopyAssignment(returnVariable, logicTerm)]
	}
	
	protected def dispatch generate(DataOperation dataOperation, Pair<Data, Variable> returnVariable, Map<Data, LogicTerm> availableData, IQueryExecutor queryExecutor, Optional<AssemblyContext> ac) {
		/*
		 * CharacteristicChangingDataOperation: see implementation
		 * ConsumeDataOperation: no action needed (except for ReturnDataOperation)
		 * CreateDataOperation: disable all properties and copy initial characteristics
		 * LoadDataOperation: disable all properties and copy default characteristics
		 * ManyToOneDataOperation: default handling not possible
		 * PerformDataTransmissionOperation: already handled in behaviour transformation
		 * TransformDataOperation: see implementation
		 */
		
		#[]
	}
	
	protected def dispatch generate(ReturnDataOperation dataOperation, Pair<Data, Variable> returnVariable, Map<Data, LogicTerm> availableData, IQueryExecutor queryExecutor, Optional<AssemblyContext> ac) {
		val variable = returnVariable.value
		val term = availableData.get(returnVariable.key)
		#[createCopyAssignment(variable, term)]
	}
	
	protected def dispatch generate(CharacteristicChangingDataOperation<?> dataOperation, Pair<Data, Variable> returnVariable, Map<Data, LogicTerm> availableData, IQueryExecutor queryExecutor, Optional<AssemblyContext> ac) {
		val result = new ArrayList<VariableAssignment>()
		val variable = returnVariable.value
		
		// always: copy all characteristics from input to output
		result += createCopyAssignment(variable, availableData.get(returnVariable.key))
		
		result += variable.createChangeAssignments(dataOperation.operation, queryExecutor, dataOperation.characteristic, dataOperation.characteristic.characteristicType)
		result
	}
	
	protected def dispatch generate(CreateDataOperation dataOperation, Pair<Data, Variable> returnVariable, Map<Data, LogicTerm> availableData, extension IQueryExecutor queryExecutor, Optional<AssemblyContext> ac) {
		returnVariable.value.createAssignments(dataOperation.initialCharacteristics, queryExecutor)
	}
	
	protected def dispatch generate(LoadDataOperation dataOperation, Pair<Data, Variable> returnVariable, Map<Data, LogicTerm> availableData, extension IQueryExecutor queryExecutor, Optional<AssemblyContext> ac) {
		// copy default characteristics if existing
		if (!StereotypeAPI.hasAppliedStereotype(#{ac.get}, ProfileConstants.STEREOTYPE_NAME_STORE_CHARACTERIZATION)) {
			return #[]
		}

		val variable = returnVariable.value
		val defaultCharacteristicContainer = EMFUtils.getTaggedValue(ac.get, ProfileConstants.TAGGED_VALUE_NAME_STORE_CHARACTERIZATION, ProfileConstants.STEREOTYPE_NAME_STORE_CHARACTERIZATION, StoreCharacteristicContainer)
		val defaultCharacteristics = defaultCharacteristicContainer.characteristics.findFirst[c | c.store === dataOperation.store]
		
		variable.createAssignments(defaultCharacteristics.ownedCharacteristics, queryExecutor)
	}
//	
//	protected def dispatch generate(TransformDataOperation dataOperation, Pair<Data, Variable> returnVariable, Map<Data, LogicTerm> availableData, IQueryExecutor queryExecutor, Optional<AssemblyContext> ac) {
//		// copy everything from input to output while ignoring parameter data
//		#[createCopyAssignment(returnVariable.value, availableData.get(dataOperation.input))]
//	}
	
}