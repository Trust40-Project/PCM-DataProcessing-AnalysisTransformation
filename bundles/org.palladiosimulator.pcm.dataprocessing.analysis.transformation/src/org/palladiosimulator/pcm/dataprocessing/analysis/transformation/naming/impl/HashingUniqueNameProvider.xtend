package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.naming.impl

import de.uka.ipd.sdq.identifier.Identifier
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.dto.IdentifierInstance
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.util.Hash
import org.palladiosimulator.pcm.repository.PrimitiveDataType
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.naming.AbstractUniqueNameProvider

class HashingUniqueNameProvider extends AbstractUniqueNameProvider {
	
	override protected generateName(Identifier identifier) {
		Hash.init(identifier.id).hash
	}
	
	override protected generateName(IdentifierInstance<?, ?> identifierInstance) {
		var identifierId = ""
		if (identifierInstance.identifier.isPresent) {
			identifierId = (identifierInstance.identifier.get as Identifier).id
		}
		Hash.init(identifierId).add(identifierInstance.entity.id).hash
	}
	
	override protected generateName(PrimitiveDataType dataType) {
		Hash.init(PrimitiveDataType.name).add(dataType.type.getName).hash
	}
	
}
