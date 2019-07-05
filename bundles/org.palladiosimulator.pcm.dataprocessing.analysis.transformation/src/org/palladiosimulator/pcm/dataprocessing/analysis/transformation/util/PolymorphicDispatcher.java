package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.util;

public interface PolymorphicDispatcher<SuperType, DispatchMethodType extends DispatchMethod<SuperType>> {

	DispatchMethodType getDispatchMethod(Class<? extends SuperType> type);
	
}
