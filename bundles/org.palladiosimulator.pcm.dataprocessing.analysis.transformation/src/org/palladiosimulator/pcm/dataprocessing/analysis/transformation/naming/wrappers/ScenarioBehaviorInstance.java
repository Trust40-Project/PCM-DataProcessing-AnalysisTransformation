package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.naming.wrappers;

import org.palladiosimulator.pcm.usagemodel.ScenarioBehaviour;

public class ScenarioBehaviorInstance extends IdentifierAssemblyContextInstance<ScenarioBehaviour> {

	protected ScenarioBehaviorInstance(ScenarioBehaviour entity) {
		super(entity, null);
	}

	public static ScenarioBehaviorInstance createInstance(ScenarioBehaviour entity) {
		return new ScenarioBehaviorInstance(entity);
	}
}
