package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.basic.impl

import de.uka.ipd.sdq.identifier.Identifier
import org.palladiosimulator.pcm.core.composition.AssemblyConnector
import org.palladiosimulator.pcm.core.composition.AssemblyContext
import org.palladiosimulator.pcm.core.entity.Entity
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.dto.IdentifierInstance
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.processing.DataOperation
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.processing.ReturnDataOperation
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.repository.OperationSignatureDataRefinement
import org.palladiosimulator.pcm.dataprocessing.profile.api.ProfileConstants
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.OperationCall
import org.palladiosimulator.pcm.repository.OperationRequiredRole
import org.palladiosimulator.pcm.seff.ExternalCallAction
import org.palladiosimulator.pcm.seff.ResourceDemandingSEFF
import org.palladiosimulator.pcm.system.System

import static org.palladiosimulator.pcm.dataprocessing.analysis.transformation.util.EMFUtils.*

import static extension org.palladiosimulator.pcm.dataprocessing.analysis.transformation.dto.IdentifierInstance.createInstance

class SEFFBehaviorTransformator extends BehaviorTransformator {
	
	new(TransformationFacilities transformationFacilities) {
		super(transformationFacilities)
	}
	
	override protected determineCalledSEFF(Iterable<Entity> callAction, IdentifierInstance<? extends Entity, AssemblyContext> callerInstance) {
		val eca = callAction.filter(ExternalCallAction).findFirst[true]
		
		val calledOperationSignature = eca.calledService_ExternalService
		val calledInterface = calledOperationSignature.interface__OperationSignature
		
		val ownAssemblyContext = callerInstance.identifier.get
		val ownComponent = ownAssemblyContext.encapsulatedComponent__AssemblyContext
		val ownRoleCandidates = ownComponent.requiredRoles_InterfaceRequiringEntity.filter(OperationRequiredRole).filter[r | r.requiredInterface__OperationRequiredRole === calledInterface]
		
		val pcmSystem = getParentOfType(ownAssemblyContext, System).get
		val assemblyConnectorCandidates = pcmSystem.connectors__ComposedStructure.filter(AssemblyConnector).filter[c | c.requiringAssemblyContext_AssemblyConnector === ownAssemblyContext && ownRoleCandidates.exists[r | r === c.requiredRole_AssemblyConnector]]
		
		val targetSEFFCandidates = assemblyConnectorCandidates.map[providingAssemblyContext_AssemblyConnector].toSet.flatMap[findAllSEFFs].filter[s | s.entity.describedService__SEFF === calledOperationSignature]
		targetSEFFCandidates.findFirst[true]
	}
	
	override protected createReturnVariables(IdentifierInstance<? extends Identifier, AssemblyContext> behaviorIdentifier) {
		val seff = behaviorIdentifier.entity as ResourceDemandingSEFF
		val signature = seff.describedService__SEFF
		
		val signatureRefinement = tryGetTaggedValue(signature, ProfileConstants.TAGGED_VALUE_NAME_OPERATION_SIGNATURE_DATA_REFINEMENT, ProfileConstants.STEREOTYPE_NAME_OPERATION_SIGNATURE_DATA_REFINEMENT, OperationSignatureDataRefinement)
		signatureRefinement.map([sr | sr.resultRefinements.map[getReturnVariable(behaviorIdentifier)]]).orElse(#[])
	}
	
	override protected createStateVariables(IdentifierInstance<? extends Identifier, AssemblyContext> behaviorIdentifier) {
		val seff = behaviorIdentifier.entity as ResourceDemandingSEFF
		val signature = seff.describedService__SEFF
		val signatureRefinement = tryGetTaggedValue(signature, ProfileConstants.TAGGED_VALUE_NAME_OPERATION_SIGNATURE_DATA_REFINEMENT, ProfileConstants.STEREOTYPE_NAME_OPERATION_SIGNATURE_DATA_REFINEMENT, OperationSignatureDataRefinement)
		signatureRefinement.map([sr | sr.parameterRefinements.map[getStateVariable(behaviorIdentifier)]]).orElse(#[])
	}
	
	override protected findAllDataOps(Identifier identifier) {
		(identifier as ResourceDemandingSEFF).findAllDataOperations
	}
	
	override protected createReturnValueAssignmentsForConsumerOperations(DataOperation consumerDataOp, AssemblyContext selfAssemblyContext, IdentifierInstance<? extends Identifier, AssemblyContext> selfInstance, OperationCall consumerOpCall) {
		if (!(consumerDataOp instanceof ReturnDataOperation)) {
			return #[]
		}
		
		val returnOp = consumerDataOp as ReturnDataOperation
		
		val returnOpInstance = selfAssemblyContext.createInstance(returnOp)
		
		val returnOpData = returnOp.consumedData
		val seffReturnedData = returnOp.returnDestination
		
		val seffReturnVariable = seffReturnedData.getReturnVariable(selfInstance)
		val returnOpReturnVariable = returnOpData.getReturnVariable(returnOpInstance)
		
		val returnValueRef = factory.createReturnValueRef
		returnValueRef.call = consumerOpCall
		returnValueRef.returnValue = returnOpReturnVariable
		
		val returnVariableAssignment = factory.createVariableAssignment
		returnVariableAssignment.variable = seffReturnVariable
		returnVariableAssignment.term = returnValueRef
		
		#[returnVariableAssignment]
	}
	
	override protected getPropertySource(IdentifierInstance<? extends Identifier, AssemblyContext> instance) {
		instance.identifier.get.resourceContainer
	}
	
}