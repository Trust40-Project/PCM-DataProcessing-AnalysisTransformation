package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.dto;

import java.util.Optional;

import org.palladiosimulator.pcm.core.entity.Entity;

import de.uka.ipd.sdq.identifier.Identifier;

public class IdentifierInstance<ENTITY_TYPE extends Identifier, IDENTIFIER_TYPE extends Identifier> {

	private final Optional<IDENTIFIER_TYPE> identifier;
	private final ENTITY_TYPE entity;

	public IdentifierInstance(ENTITY_TYPE entity, IDENTIFIER_TYPE identifier) {
		super();
		this.identifier = Optional.ofNullable(identifier);
		this.entity = entity;
	}

	public Optional<IDENTIFIER_TYPE> getIdentifier() {
		return identifier;
	}

	public ENTITY_TYPE getEntity() {
		return entity;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((identifier == null) ? 0 : identifier.hashCode());
		result = prime * result + ((entity == null) ? 0 : entity.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		@SuppressWarnings("rawtypes")
		IdentifierInstance other = (IdentifierInstance) obj;
		if (identifier == null) {
			if (other.identifier != null)
				return false;
		} else if (!identifier.equals(other.identifier))
			return false;
		if (entity == null) {
			if (other.entity != null)
				return false;
		} else if (!entity.equals(other.entity))
			return false;
		return true;
	}
	
	@Override
	public String toString() {
		String entityName = Optional.of(entity).filter(Entity.class::isInstance).map(Entity.class::cast)
				.map(Entity::getEntityName).orElse(entity.getId());
		String identifierId = identifier.map(Identifier::getId).orElse("");

		return String.format("IdentifierInstance[%s] (Entity: %s, Identifier: %s)", entity.eClass().getName(), entityName, identifierId);
	}

	public static <ENTITY_TYPE extends Identifier, IDENTIFIER_TYPE extends Identifier> IdentifierInstance<ENTITY_TYPE, IDENTIFIER_TYPE> createInstance(
			IDENTIFIER_TYPE identifier, ENTITY_TYPE entity) {
		return new IdentifierInstance<ENTITY_TYPE, IDENTIFIER_TYPE>(entity, identifier);
	}

}
