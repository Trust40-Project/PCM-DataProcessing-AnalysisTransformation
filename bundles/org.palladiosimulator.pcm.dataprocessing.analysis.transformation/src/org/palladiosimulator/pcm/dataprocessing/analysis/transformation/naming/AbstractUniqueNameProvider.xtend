package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.naming

import de.uka.ipd.sdq.identifier.Identifier
import org.palladiosimulator.pcm.core.entity.Entity
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.basic.impl.DataTypeWrapper
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.dto.IdentifierInstance
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.naming.IUniqueNameProvider
import org.palladiosimulator.pcm.repository.DataType
import org.palladiosimulator.pcm.repository.PrimitiveDataType

abstract class AbstractUniqueNameProvider implements IUniqueNameProvider {
	
	override uniqueName(Object entity) {
		entity.uniqueNameInternal
	}
	
	protected def dispatch String uniqueNameInternal(Identifier entity) {
		entity.generateName
	}
	
	protected abstract def String generateName(Identifier identifier)
	
	protected def dispatch String uniqueNameInternal(IdentifierInstance<?, ?> identifierInstance) {
		identifierInstance.generateName
	}
	
	protected abstract def String generateName(IdentifierInstance<?, ?> identifierInstance)
	
	protected def dispatch String uniqueNameInternal(DataType dataType) {
		dataType.uniqueNameDataType
	}
	
	protected def dispatch String uniqueNameDataType(PrimitiveDataType dataType) {
		dataType.generateName
	}
	
	protected abstract def String generateName(PrimitiveDataType dataType)
	
	protected def dispatch String uniqueNameDataType(Entity dataType) {
		dataType.uniqueNameInternal
	}
	
	protected def dispatch String uniqueNameDataType(DataTypeWrapper dataType) {
		dataType.delegate.uniqueNameDataType
	}
	
}
