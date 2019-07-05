package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.dto;

import org.palladiosimulator.pcm.core.composition.AssemblyContext;
import org.palladiosimulator.pcm.seff.ResourceDemandingSEFF;

public class SEFFInstance extends IdentifierInstance<ResourceDemandingSEFF, AssemblyContext> {

	public SEFFInstance(ResourceDemandingSEFF entity, AssemblyContext ac) {
		super(entity, ac);
	}
	
	public AssemblyContext getAc() {
		return getIdentifier().get();
	}


	public static SEFFInstance createInstance(AssemblyContext identifier,
			ResourceDemandingSEFF entity) {
		return new SEFFInstance(entity, identifier);
	}
	
}
