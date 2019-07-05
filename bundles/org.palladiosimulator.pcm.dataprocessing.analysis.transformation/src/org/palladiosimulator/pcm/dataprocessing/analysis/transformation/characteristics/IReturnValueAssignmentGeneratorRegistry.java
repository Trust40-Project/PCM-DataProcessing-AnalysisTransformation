package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics;

public interface IReturnValueAssignmentGeneratorRegistry {

	/**
	 * 
	 * @return Generators starting from lowest to highest priority.
	 */
	Iterable<IReturnValueAssignmentGenerator> getGenerators();

}