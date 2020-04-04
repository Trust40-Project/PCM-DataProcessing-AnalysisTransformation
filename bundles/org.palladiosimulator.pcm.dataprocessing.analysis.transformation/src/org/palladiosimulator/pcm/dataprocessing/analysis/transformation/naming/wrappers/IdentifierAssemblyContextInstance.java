package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.naming.wrappers;

import org.palladiosimulator.pcm.core.composition.AssemblyContext;

import de.uka.ipd.sdq.identifier.Identifier;

public class IdentifierAssemblyContextInstance<ENTITY_TYPE extends Identifier> extends IdentifierInstance<ENTITY_TYPE, AssemblyContext> {

	public IdentifierAssemblyContextInstance(ENTITY_TYPE entity, AssemblyContext identifier) {
		super(entity, identifier);
	}

	public AssemblyContext getAc() {
		return getIdentifier().get();
	}
}
