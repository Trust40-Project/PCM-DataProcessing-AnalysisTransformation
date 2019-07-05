package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.naming.impl

import com.google.common.collect.BiMap
import com.google.common.collect.HashBiMap
import com.google.common.collect.ImmutableBiMap
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.naming.ICachingUniqueNameProvider
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.naming.IUniqueNameProvider

class CachingUniqueNameProvider implements ICachingUniqueNameProvider {
	
	val BiMap<Object, String> cache = HashBiMap.create
	val IUniqueNameProvider provider
	
	new (IUniqueNameProvider provider) {
		this.provider = provider
	}
	
	override getCache() {
		ImmutableBiMap.copyOf(cache)
	}
	
	override uniqueName(Object entity) {
		cache.computeIfAbsent(entity, [provider.uniqueName(entity)])
	}
	
}
