package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.basic;

import org.palladiosimulator.pcm.allocation.Allocation;
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.characteristics.CharacteristicTypeContainer;
import org.palladiosimulator.pcm.usagemodel.UsageModel;

public interface ITransformator {

	org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.System transform(UsageModel pcmUsageModel,
			Allocation pcmAllocationModel, CharacteristicTypeContainer pcmCharacteristicTypeContainer);

}
