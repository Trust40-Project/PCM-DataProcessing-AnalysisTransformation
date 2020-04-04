package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.naming.wrappers;

import org.palladiosimulator.pcm.core.composition.AssemblyContext;
import org.palladiosimulator.pcm.seff.ResourceDemandingSEFF;

public class SEFFInstance extends IdentifierAssemblyContextInstance<ResourceDemandingSEFF> {

	public SEFFInstance(ResourceDemandingSEFF entity, AssemblyContext ac) {
		super(entity, ac);
	}

	public static SEFFInstance createInstance(AssemblyContext identifier,
			ResourceDemandingSEFF entity) {
		return new SEFFInstance(entity, identifier);
	}
	
}
