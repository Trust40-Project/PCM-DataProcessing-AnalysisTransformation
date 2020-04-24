package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.basic;

import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.naming.wrappers.IdentifierAssemblyContextInstance;
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.data.Data;

public interface VariableSourceTraceEntry {

    VariablePurpose getPurpose();
    Data getData();
    IdentifierAssemblyContextInstance<?> getContext();
    
}
