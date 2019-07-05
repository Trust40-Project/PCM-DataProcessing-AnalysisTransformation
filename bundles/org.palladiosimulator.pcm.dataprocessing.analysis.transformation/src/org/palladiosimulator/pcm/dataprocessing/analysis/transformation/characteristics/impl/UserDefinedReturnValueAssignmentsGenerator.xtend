package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics.impl

import java.util.ArrayList
import java.util.Map
import java.util.Optional
import org.osgi.service.component.annotations.Component
import org.palladiosimulator.pcm.core.composition.AssemblyContext
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics.IQueryExecutor
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics.IReturnValueAssignmentGenerator
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.data.Data
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.processing.DataOperation
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.LogicTerm
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.Variable
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.VariableAssignment

import static extension org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics.impl.AssignmentsGeneratorUtils.*

@Component
class UserDefinedReturnValueAssignmentsGenerator implements IReturnValueAssignmentGenerator {
	
	override getProducedType() {
		ProducedAssignmentType.OTHER
	}
	
	override generateAssignments(IQueryExecutor queryExecutor, Optional<AssemblyContext> ac, DataOperation dataOperation, Map<Data, LogicTerm> availableData, Map<Data, Variable> returnVariables) {
		val result = new ArrayList<VariableAssignment>()
		
		for (returnVariableEntry : returnVariables.entrySet) {
			val returnData = returnVariableEntry.key
			val returnVariable = returnVariableEntry.value
			
			val relevantProcessingEffects = dataOperation.processingEffectProvider.processingEffects.filter[isApplicableTo(dataOperation, returnData)]
			for (characteristicChange : relevantProcessingEffects.map[characteristicChanges].flatten) {
				
				for (changeSpecification : characteristicChange.characteristicSpecifications) {
					result += changeSpecification.createChangeAssignmentsBySpecification(returnVariable, queryExecutor)
				}
				
			}
		}
		
		result
	}

}