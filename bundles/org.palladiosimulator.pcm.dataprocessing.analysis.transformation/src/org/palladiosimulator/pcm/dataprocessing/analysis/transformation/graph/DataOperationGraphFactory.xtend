package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.graph

import java.util.HashSet
import java.util.LinkedList
import java.util.List
import org.eclipse.emf.ecore.EObject
import org.jgrapht.Graph
import org.jgrapht.graph.DirectedMultigraph
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.dto.DataEdge
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.processing.DataOperation

class DataOperationGraphFactory {
	
	val DataOperation dummyOperation
	
	new(DataOperation dummyOperation) {
		this.dummyOperation = dummyOperation
	}
	
	def Graph<DataOperation, DataEdge> createDataOpGraph(Iterable<DataOperation> dataOps) {
 		val graphBuilder = DirectedMultigraph.createBuilder(DataEdge)
 		dataOps.forEach[o | graphBuilder.addVertex(o)]
 		graphBuilder.addVertex(dummyOperation)
 		
 		val unprocessedDataOperations = new HashSet<DataOperation>()
 		unprocessedDataOperations.addAll(dataOps)
 		val operationQueue = new LinkedList<DataOperation>()
 		operationQueue.addAll(dataOps.filter[op | op.outgoingData.isEmpty]) // assumption: every data flow is terminated by a consumer
 		while (!operationQueue.isEmpty) {
 			val currentOperation = operationQueue.pop
 			unprocessedDataOperations.remove(currentOperation)
 			val requirements = currentOperation.incomingData
 			for (requirement : requirements) {
 				var providers = dataOps.filter[dataOp | dataOp.outgoingData.contains(requirement)]
 				val originalProvidersSuccessors = providers.filter[incomingData.contains(requirement)].toList
 				val originalProviders = providers.filter[p | !originalProvidersSuccessors.contains(p)]
 				if (originalProviders.size > 1) {
 					throw new IllegalStateException("There has to be exactly one provider for a data instance.")
 				}
 				val originalProvider = if (originalProviders.size == 1)  originalProviders.iterator.next else dummyOperation
				val sortedProviderChain = (#[originalProvider] + originalProvidersSuccessors.sortBy[containerIndex]).toList
				
				var providerIndex = sortedProviderChain.indexOf(currentOperation) - 1
				if (providerIndex < 0) {
					providerIndex = sortedProviderChain.size - 1
				}
 				var provider = sortedProviderChain.get(providerIndex)

 				operationQueue.add(provider)
				graphBuilder.addEdge(provider, currentOperation, new DataEdge(requirement))
 			}
 		}
 		
 		if (!unprocessedDataOperations.empty) {
 			throw new IllegalStateException("There are unreachable data processing operations defined in the behaviour.");
 		}
 		
 		graphBuilder.build
	}
	
	protected static def getContainerIndex(EObject obj) {
		val containerFeature = obj.eContainmentFeature
		if (containerFeature !== null && containerFeature.isMany) {
			val containerList = obj.eContainer.eGet(containerFeature) as List<EObject>
			return containerList.indexOf(obj)
		}
		return 0
	}
}