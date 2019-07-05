package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.util;

import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class HeuristicPolymorphicDispatcher<SuperType, DispatchMethodType extends DispatchMethod<SuperType>>
		implements PolymorphicDispatcher<SuperType, DispatchMethodType> {

	private final Map<Class<? extends SuperType>, DispatchMethodType> dispatchers = new HashMap<>();
	private final Map<Class<? extends SuperType>, DispatchMethodType> cache = new HashMap<>();

	public void addDispatchMethod(DispatchMethodType method) {
		dispatchers.put(method.getSupportedClass(), method);
		cache.clear();
	}

	@Override
	public DispatchMethodType getDispatchMethod(Class<? extends SuperType> type) {
		return cache.computeIfAbsent(type, this::findMatchingMethod);
	}

	protected DispatchMethodType findMatchingMethod(Class<? extends SuperType> type) {
		return dispatchers.get(findClosestClass(type));
	}

	protected Class<? extends SuperType> findClosestClass(Class<? extends SuperType> type) {
		Map<Integer, List<Class<? extends SuperType>>> distanceGroups = dispatchers.keySet().stream()
				.filter(c -> c.isAssignableFrom(type))
				.collect(Collectors.groupingBy(c -> Integer.valueOf(getDistance(type, c))));
		List<Class<? extends SuperType>> minimalDistanceGroup = distanceGroups.keySet().stream().min(Integer::compare)
				.map(distanceGroups::get).orElse(Collections.emptyList());
		if (minimalDistanceGroup.size() == 1) {
			return minimalDistanceGroup.iterator().next();
		}
		// this might be ambiguous
		List<Class<? extends SuperType>> classCandidates = minimalDistanceGroup.stream()
				.filter(c -> !c.isInterface() && !c.isEnum()).collect(Collectors.toList());
		if (classCandidates.size() > 0) {
			return classCandidates.iterator().next();
		}
		return minimalDistanceGroup.iterator().next();
	}

	protected static int getDistance(Class<?> clz, Class<?> parentCandidate) {
		assert (parentCandidate.isAssignableFrom(clz));

		Collection<Class<?>> nextLevelQueue = new LinkedList<>();
		nextLevelQueue.add(parentCandidate);

		for (int i = 0; !nextLevelQueue.isEmpty(); ++i) {
			LinkedList<Class<?>> queue = new LinkedList<>(nextLevelQueue);
			nextLevelQueue.clear();
			while (!queue.isEmpty()) {
				Class<?> currentClass = queue.pop();
				if (currentClass == clz) {
					return i;
				}
				nextLevelQueue.add(currentClass.getSuperclass());
				nextLevelQueue.addAll(Arrays.asList(currentClass.getInterfaces()));
			}
		}

		// should never happen because of precondition
		return Integer.MAX_VALUE;
	}

}
