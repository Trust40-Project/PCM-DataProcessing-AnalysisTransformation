package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.basic.impl;

import java.util.Optional;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.basic.ITransformator;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.basic.ITransformatorFactory;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics.IReturnValueAssignmentGeneratorRegistry;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.naming.IUniqueNameProvider;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.naming.impl.CachingUniqueNameProvider;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.naming.impl.HashingUniqueNameProvider;

@Component
public class TransformatorFactoryImpl implements ITransformatorFactory {

	@Reference
	private IReturnValueAssignmentGeneratorRegistry registry;
	
	@Override
	public ITransformator create(final IReturnValueAssignmentGeneratorRegistry registry, final IUniqueNameProvider nameProvider) {
		IReturnValueAssignmentGeneratorRegistry registryToUse = Optional.ofNullable(registry).orElse(this.registry);
		IUniqueNameProvider uniqueNameProvider = Optional.ofNullable(nameProvider).orElseGet(() -> new HashingUniqueNameProvider());
		return new PCM2DFSystemModelTransformation(registryToUse, new CachingUniqueNameProvider(uniqueNameProvider));
	}

}
