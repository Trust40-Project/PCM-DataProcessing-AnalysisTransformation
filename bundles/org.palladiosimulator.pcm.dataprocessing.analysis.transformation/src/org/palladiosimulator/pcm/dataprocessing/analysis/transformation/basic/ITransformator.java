package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.basic;

import org.apache.commons.lang3.mutable.Mutable;
import org.apache.commons.lang3.mutable.MutableObject;
import org.palladiosimulator.pcm.allocation.Allocation;
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.characteristics.CharacteristicTypeContainer;
import org.palladiosimulator.pcm.usagemodel.UsageModel;

public interface ITransformator {

	default org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.System transform(UsageModel pcmUsageModel,
			Allocation pcmAllocationModel, CharacteristicTypeContainer pcmCharacteristicTypeContainer) {
		return transform(pcmUsageModel, pcmAllocationModel, pcmCharacteristicTypeContainer, new MutableObject<>());
	}

	/**
	 * Transforms the given Palladio models to a system model.
	 * @param pcmUsageModel The PCM usage model.
	 * @param pcmAllocationModel The PCM allocation model.
	 * @param pcmCharacteristicTypeContainer The characteristic type container that contains all used characteristic types.
	 * @param idTrace Writable, empty map for the ID trace. Will contain the trace after the transformation.
	 * @return System model root object as transformation result of the input parameters.
	 */
	org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.System transform(UsageModel pcmUsageModel,
			Allocation pcmAllocationModel, CharacteristicTypeContainer pcmCharacteristicTypeContainer, Mutable<ITransformationTrace> traceWrapper);

}
