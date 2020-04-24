package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.basic.impl;

import java.util.Optional;

import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.basic.ITransformationTrace;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.basic.VariableSourceTraceEntry;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.naming.wrappers.DataOperationInstance;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.naming.wrappers.SEFFInstance;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.naming.wrappers.ScenarioBehaviorInstance;
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.Variable;
import org.palladiosimulator.pcm.repository.DataType;

import com.google.common.collect.BiMap;
import com.google.common.collect.HashBiMap;

import de.uka.ipd.sdq.identifier.Identifier;

public class TransformationTraceImpl implements ITransformationTrace {

	private BiMap<Object, String> nameCache = HashBiMap.create();
	private BiMap<VariableSourceTraceEntry, String> variableCache = HashBiMap.create();

	public void addVariableMapping(VariableSourceTraceEntry source, Variable variable) {
	    variableCache.put(source, variable.getName());
	}
	
	public void addNameCache(BiMap<Object, String> nameCache) {
	    this.nameCache.putAll(nameCache);
	}

	@Override
	public Optional<SEFFInstance> resolveSeffInstance(String id) {
		return findBySystemModelId(id, SEFFInstance.class);
	}

	@Override
	public Optional<DataType> resolveDataType(String id) {
		return findBySystemModelId(id, DataTypeWrapper.class).map(DataTypeWrapper::getDelegate);
	}

	@Override
	public Optional<DataOperationInstance> resolveDataOperationInstance(String id) {
		return findBySystemModelId(id, DataOperationInstance.class);
	}

	@Override
	public Optional<Identifier> resolveIdentifier(String id) {
		Optional<Object> foundElement = findBySystemModelId(id);
		if (!foundElement.isPresent()) {
			return Optional.empty();
		}

		Optional<Identifier> behavior = castToType(foundElement, ScenarioBehaviorInstance.class)
				.map(ScenarioBehaviorInstance::getEntity);
		if (behavior.isPresent()) {
			return behavior;
		}

		return castToType(foundElement, Identifier.class);
	}

	@Override
	public Optional<String> resolveId(SEFFInstance entity) {
		return getOptionalId(entity);
	}

	@Override
	public Optional<String> resolveId(DataOperationInstance entity) {
		return getOptionalId(entity);
	}

	@Override
	public Optional<String> resolveId(DataType entity) {
		return getOptionalId(entity);
	}

	@Override
	public Optional<String> resolveId(Identifier entity) {
		return getOptionalId(entity);
	}

	protected <T> Optional<T> findBySystemModelId(String id, Class<T> clazz) {
		return castToType(findBySystemModelId(id), clazz);
	}

	protected Optional<Object> findBySystemModelId(String id) {
		return Optional.ofNullable(nameCache.inverse().get(id));
	}

	protected static <T> Optional<T> castToType(Optional<Object> element, Class<T> clazz) {
		return element.filter(clazz::isInstance).map(clazz::cast);
	}

	protected Optional<String> getOptionalId(Object o) {
		return Optional.ofNullable(nameCache.get(o));
	}

    @Override
    public Optional<VariableSourceTraceEntry> resolveVariable(String id) {
        return Optional.ofNullable(variableCache.inverse().get(id));
    }

    @Override
    public Optional<String> resolveId(VariableSourceTraceEntry entity) {
        return Optional.ofNullable(variableCache.get(entity));
    }

}
