package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.basic;

import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.Activator;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics.IReturnValueAssignmentGeneratorRegistry;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.naming.IUniqueNameProvider;

public interface ITransformatorFactory {

	default ITransformator create() {
		return create(null, null);
	}
	
	ITransformator create(IReturnValueAssignmentGeneratorRegistry registry, IUniqueNameProvider nameProvider);
	
	static ITransformatorFactory getInstance() {
		return Activator.getInstance().getTransformatorFactoryInstance();
	}
}
