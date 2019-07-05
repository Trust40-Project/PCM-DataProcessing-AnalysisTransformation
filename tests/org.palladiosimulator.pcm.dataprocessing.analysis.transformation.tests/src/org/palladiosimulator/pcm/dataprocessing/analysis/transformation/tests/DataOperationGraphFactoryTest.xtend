package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.tests

import java.io.File
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.EcoreUtil
import org.junit.Before
import org.junit.BeforeClass
import org.junit.Test
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.graph.DataOperationGraphFactory
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.tests.base.StandaloneInitializer
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.DataSpecification
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.processing.ProcessingFactory

import static org.junit.Assert.*

class DataOperationGraphFactoryTest {

	static val OP_FACTORY = ProcessingFactory.eINSTANCE
	static val DUMMY_OPERATION = OP_FACTORY.createReturnDataOperation
	static val PROJECT_NAME = "org.palladiosimulator.pcm.dataprocessing.analysis.transformation.tests"
	
	DataOperationGraphFactory subject
	
	@BeforeClass
	static def void init() {
		StandaloneInitializer.initStandalone
		StandaloneInitializer.registerProjectURI(DataOperationGraphFactoryTest, PROJECT_NAME)
	}
	
	protected static def createRelativeURI(String relativePath) {
		if (StandaloneInitializer.isRunningEmbedded) {
			return URI.createFileURI(new File(relativePath).getAbsolutePath());
		}
		return StandaloneInitializer.createProjectRelativeURI(PROJECT_NAME, relativePath);
	}
	
	@Before
	def void setup() {
		subject = new DataOperationGraphFactory(DUMMY_OPERATION)
	}
	
	@Test
	def testSimple() {
		val rs = new ResourceSetImpl();
		val dataSpecification = rs.getResource(createRelativeURI("models/minimalCallAndReturn/DataSpecification.xmi"), true).getContents().get(0) as DataSpecification
		EcoreUtil.resolveAll(rs);
		val container = dataSpecification.dataProcessingContainers.findFirst[id == "seffReadWriteEchoData"]
		
		val actual = subject.createDataOpGraph(container.operations)
		assertEquals(2, actual.vertexSet.size)
		assertEquals(1, actual.edgeSet.size)
		assertEquals(1, actual.outgoingEdgesOf(DUMMY_OPERATION).size)
		assertEquals(0, actual.incomingEdgesOf(DUMMY_OPERATION).size)
		assertEquals(0, actual.outgoingEdgesOf(actual.vertexSet.findFirst[v | v !== DUMMY_OPERATION]).size)
	}
	
	@Test
	def testSameDataChain() {
		val rs = new ResourceSetImpl();
		val dataSpecification = rs.getResource(createRelativeURI("models/graph_sameDataChain.xmi"), true).getContents().get(0) as DataSpecification
		EcoreUtil.resolveAll(rs);
		val container = dataSpecification.dataProcessingContainers.findFirst[true]
		
		
		val actual = subject.createDataOpGraph(container.operations)
		
		assertEquals(5, actual.vertexSet.size)
		assertEquals(3, actual.edgeSet.size)
		
		assertEquals(0, actual.incomingEdgesOf(DUMMY_OPERATION).size)
		assertEquals(0, actual.outgoingEdgesOf(DUMMY_OPERATION).size)
		
		assertEquals(0, actual.incomingEdgesOf(container.operations.get(0)).size)
		assertEquals(1, actual.outgoingEdgesOf(container.operations.get(0)).size)
		assertEquals(container.operations.get(1), actual.outgoingEdgesOf(container.operations.get(0)).iterator.next.findTarget)
		
		assertEquals(1, actual.incomingEdgesOf(container.operations.get(1)).size)
		assertEquals(1, actual.outgoingEdgesOf(container.operations.get(1)).size)
		assertEquals(container.operations.get(2), actual.outgoingEdgesOf(container.operations.get(1)).iterator.next.findTarget)
		
		assertEquals(1, actual.incomingEdgesOf(container.operations.get(2)).size)
		assertEquals(1, actual.outgoingEdgesOf(container.operations.get(2)).size)
		assertEquals(container.operations.get(3), actual.outgoingEdgesOf(container.operations.get(2)).iterator.next.findTarget)
		
		assertEquals(1, actual.incomingEdgesOf(container.operations.get(3)).size)
		assertEquals(0, actual.outgoingEdgesOf(container.operations.get(3)).size)
		
	}
	
	@Test
	def testSameDataSource() {
		val rs = new ResourceSetImpl();
		val dataSpecification = rs.getResource(createRelativeURI("models/graph_sameSource.xmi"), true).getContents().get(0) as DataSpecification
		EcoreUtil.resolveAll(rs);
		val container = dataSpecification.dataProcessingContainers.findFirst[true]
		
		
		val actual = subject.createDataOpGraph(container.operations)
		
		assertEquals(2, actual.vertexSet.size)
		assertEquals(2, actual.edgeSet.size)
		
		assertEquals(0, actual.incomingEdgesOf(DUMMY_OPERATION).size)
		assertEquals(2, actual.outgoingEdgesOf(DUMMY_OPERATION).size)
		
		assertEquals(2, actual.incomingEdgesOf(container.operations.get(0)).size)
		assertEquals(0, actual.outgoingEdgesOf(container.operations.get(0)).size)
				
	}
	
}