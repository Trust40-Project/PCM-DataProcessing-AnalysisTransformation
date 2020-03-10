package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.basic;

import java.util.Map;

import org.palladiosimulator.pcm.allocation.Allocation;
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.characteristics.CharacteristicTypeContainer;
import org.palladiosimulator.pcm.usagemodel.UsageModel;

public interface ITransformator {

	org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.System transform(UsageModel pcmUsageModel,
			Allocation pcmAllocationModel, CharacteristicTypeContainer pcmCharacteristicTypeContainer);

	Map<String, String> transformModelId(UsageModel usageModel, Allocation allocModel, CharacteristicTypeContainer characModel, String... modelElementIds);

}
