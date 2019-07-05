package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.util;

public interface DispatchMethod<T> {

	Class<? extends T> getSupportedClass();
	
}
