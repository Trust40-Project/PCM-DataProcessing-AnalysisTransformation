package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.naming.wrappers;

import org.palladiosimulator.pcm.core.composition.AssemblyContext;
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.processing.DataOperation;

public class DataOperationInstance extends IdentifierAssemblyContextInstance<DataOperation> {

	public DataOperationInstance(DataOperation entity, AssemblyContext identifier) {
		super(entity, identifier);
	}

	public static DataOperationInstance createInstance(AssemblyContext identifier,
			DataOperation entity) {
		return new DataOperationInstance(entity, identifier);
	}
	
}
