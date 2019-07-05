package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics.impl;

import java.util.Collections;
import java.util.TreeSet;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ServiceScope;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics.IReturnValueAssignmentGenerator;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics.IReturnValueAssignmentGeneratorRegistry;

@Component(scope=ServiceScope.SINGLETON)
public class ReturnValueAssignmentGeneratorRegistry implements IReturnValueAssignmentGeneratorRegistry {

	final TreeSet<IReturnValueAssignmentGenerator> generators = new TreeSet<>();
	
	@Reference(cardinality=ReferenceCardinality.MULTIPLE)
	public void addGenerator(IReturnValueAssignmentGenerator generator) {
		generators.add(generator);
	}
	
	public void removeGenerator(IReturnValueAssignmentGenerator generator) {
		generators.remove(generator);
	}
	
	@Override
	public Iterable<IReturnValueAssignmentGenerator> getGenerators() {
		return Collections.unmodifiableSet(generators.descendingSet());
	}
}
