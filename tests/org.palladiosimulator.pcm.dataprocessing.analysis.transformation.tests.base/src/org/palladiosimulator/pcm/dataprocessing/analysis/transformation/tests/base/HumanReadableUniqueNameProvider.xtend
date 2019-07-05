package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.tests.base

import de.uka.ipd.sdq.identifier.Identifier
import org.palladiosimulator.pcm.core.entity.Entity
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.dto.IdentifierInstance
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.naming.AbstractUniqueNameProvider
import org.palladiosimulator.pcm.repository.PrimitiveDataType

class HumanReadableUniqueNameProvider extends AbstractUniqueNameProvider {
	
	override protected generateName(Identifier identifier) {
		if (identifier instanceof Entity) {
			return '''«identifier.eClass.name» «identifier.entityName» («identifier.id»)'''
		}
		return '''«identifier.eClass.name» («identifier.id»)'''
	}
	
	override protected generateName(IdentifierInstance<?, ?> identifierInstance)
		'''«identifierInstance.entity.generateName» - AC «identifierInstance.identifier.map[id].orElse("n/a")»'''
	
	override protected generateName(PrimitiveDataType dataType)
		'''«PrimitiveDataType.name» «dataType.type.getName»'''
	
}