package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics;

import org.palladiosimulator.pcm.dataprocessing.dataprocessing.characteristics.Characteristic;
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.characteristics.CharacteristicType;
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.Attribute;
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.Value;

public interface IQueryExecutor {

	Iterable<Value> getValues(Characteristic characteristic);

	Attribute getAttribute(CharacteristicType type);

	Iterable<Value> getValues(CharacteristicType characteristicType);
	
	Iterable<CharacteristicType> getCharacteristicTypes();
}
