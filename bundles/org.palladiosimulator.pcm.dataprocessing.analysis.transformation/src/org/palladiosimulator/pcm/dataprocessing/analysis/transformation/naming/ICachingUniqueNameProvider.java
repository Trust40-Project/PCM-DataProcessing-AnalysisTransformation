package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.naming;

import com.google.common.collect.BiMap;

public interface ICachingUniqueNameProvider extends IUniqueNameProvider {

	default Object lookupObject(String uniqueName) {
		return getCache().inverse().get(uniqueName);
	}
	
	default String lookupName(Object object) {
		return getCache().get(object);
	}
	
	BiMap<Object, String> getCache();
	
}
