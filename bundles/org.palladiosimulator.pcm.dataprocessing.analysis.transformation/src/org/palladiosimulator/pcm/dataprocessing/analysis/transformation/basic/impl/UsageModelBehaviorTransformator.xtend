package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.basic.impl

import de.uka.ipd.sdq.identifier.Identifier
import java.util.ArrayList
import org.eclipse.emf.ecore.util.EcoreUtil
import org.jgrapht.Graph
import org.palladiosimulator.pcm.core.composition.AssemblyContext
import org.palladiosimulator.pcm.core.composition.ProvidedDelegationConnector
import org.palladiosimulator.pcm.core.entity.Entity
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.dto.DataEdge
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.naming.wrappers.IdentifierInstance
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.processing.DataOperation
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.OperationCall
import org.palladiosimulator.pcm.system.System
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall
import org.palladiosimulator.pcm.usagemodel.ScenarioBehaviour
import org.palladiosimulator.pcm.usagemodel.Start

class UsageModelBehaviorTransformator extends BehaviorTransformator {
	
	new(TransformationFacilities transformationFacilities) {
		super(transformationFacilities)
	}
	
	override validateDataOpGraph(Graph<DataOperation, DataEdge> dataOpGraph) {
		if (dataOpGraph.outgoingEdgesOf(SEFF_DUMMY_OPERATION).size != 0) {
			throw new IllegalStateException("A usage model cannot provide any data.")
		}
	}
	
	override protected determineCalledSEFF(Iterable<Entity> callAction, IdentifierInstance<? extends Entity, AssemblyContext> callerInstance) {
		val elsc = callAction.filter(EntryLevelSystemCall).findFirst[true]
		val calledSignature = elsc.operationSignature__EntryLevelSystemCall
		
		val providedRole = elsc.providedRole_EntryLevelSystemCall
		val pcmSystem = EcoreUtil.getRootContainer(providedRole) as System
		val targetAssembly = pcmSystem.connectors__ComposedStructure.filter(ProvidedDelegationConnector).findFirst[outerProvidedRole_ProvidedDelegationConnector === providedRole].assemblyContext_ProvidedDelegationConnector
		val targetSEFFCandidates = targetAssembly.findAllSEFFs.filter[seff | seff.entity.describedService__SEFF === calledSignature]
		targetSEFFCandidates.findFirst[true]
	}
	
	override protected createReturnVariables(IdentifierInstance<? extends Identifier, AssemblyContext> behaviorIdentifier) {
		// Usage models cannot return data
		#[]
	}
	
	override protected createStateVariables(IdentifierInstance<? extends Identifier, AssemblyContext> behaviorIdentifier) {
		// Usage models cannot state data
		#[]
	}
	
	override protected createReturnValueAssignmentsForConsumerOperations(DataOperation consumerDataOp, AssemblyContext selfAssemblyContext, IdentifierInstance<? extends Identifier, AssemblyContext> selfInstance, OperationCall consumerOpCall) {
		// Usage models cannot return data
		#[]
	}
	
	override protected findAllDataOps(Identifier identifier) {
		var ops = new ArrayList<DataOperation>();
		for (var action = (identifier as ScenarioBehaviour).actions_ScenarioBehaviour.findFirst[a | a instanceof Start]; action !== null; action = action.successor) {
			ops += action.findAllDataOperationsOfStereotpyedEObject
		}
		ops
	}
	
	override protected getPropertySource(IdentifierInstance<? extends Identifier, AssemblyContext> instance) {
		// ScenarioBehavior itself
		instance.entity
	}
	
}