package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics.impl;

import java.util.function.Function;
import java.util.function.Supplier;

import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics.IQueryExecutor;
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.characteristics.Characteristic;
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.characteristics.CharacteristicType;
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.Attribute;
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.Value;

public class QueryExecutorDelegator implements IQueryExecutor {

	private final Function<Characteristic, Iterable<Value>> getValuesForCharacteristicFunction;
	private final Function<CharacteristicType, Attribute> getAttributeFunction;
	private final Function<CharacteristicType, Iterable<Value>> getValuesForCharacteristicTypeFunction;
	private final Supplier<Iterable<CharacteristicType>> getCharacteristicTypesFunction;

	public QueryExecutorDelegator(Function<Characteristic, Iterable<Value>> getValuesForCharacteristicFunction,
			Function<CharacteristicType, Attribute> getAttributeFunction,
			Function<CharacteristicType, Iterable<Value>> getValuesForCharacteristicTypeFunction,
			Supplier<Iterable<CharacteristicType>> getCharacteristicTypesFunction) {
		super();
		this.getValuesForCharacteristicFunction = getValuesForCharacteristicFunction;
		this.getAttributeFunction = getAttributeFunction;
		this.getValuesForCharacteristicTypeFunction = getValuesForCharacteristicTypeFunction;
		this.getCharacteristicTypesFunction = getCharacteristicTypesFunction;
	}

	@Override
	public Iterable<Value> getValues(Characteristic characteristic) {
		return getValuesForCharacteristicFunction.apply(characteristic);
	}

	@Override
	public Attribute getAttribute(CharacteristicType type) {
		return getAttributeFunction.apply(type);
	}

	@Override
	public Iterable<Value> getValues(CharacteristicType characteristicType) {
		return getValuesForCharacteristicTypeFunction.apply(characteristicType);
	}

	@Override
	public Iterable<CharacteristicType> getCharacteristicTypes() {
		return getCharacteristicTypesFunction.get();
	}

}
