package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.basic.impl;

import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.basic.VariableSourceTraceEntry;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.basic.VariablePurpose;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.naming.wrappers.IdentifierAssemblyContextInstance;
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.data.Data;

public class VariableSourceTraceEntryImpl implements VariableSourceTraceEntry {
    private final VariablePurpose purpose;
    private final Data data;
    private final IdentifierAssemblyContextInstance<?> context;

    public VariableSourceTraceEntryImpl(VariablePurpose purpose, Data data,
            IdentifierAssemblyContextInstance<?> context) {
        super();
        this.purpose = purpose;
        this.data = data;
        this.context = context;
    }

    @Override
    public VariablePurpose getPurpose() {
        return purpose;
    }

    @Override
    public Data getData() {
        return data;
    }

    @Override
    public IdentifierAssemblyContextInstance<?> getContext() {
        return context;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((context == null) ? 0 : context.hashCode());
        result = prime * result + ((data == null) ? 0 : data.hashCode());
        result = prime * result + ((purpose == null) ? 0 : purpose.hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        VariableSourceTraceEntryImpl other = (VariableSourceTraceEntryImpl) obj;
        if (context == null) {
            if (other.context != null)
                return false;
        } else if (!context.equals(other.context))
            return false;
        if (data == null) {
            if (other.data != null)
                return false;
        } else if (!data.equals(other.data))
            return false;
        if (purpose != other.purpose)
            return false;
        return true;
    }

}
