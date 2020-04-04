package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.basic;

import java.util.Optional;

import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.naming.wrappers.DataOperationInstance;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.naming.wrappers.SEFFInstance;
import org.palladiosimulator.pcm.repository.DataType;

import de.uka.ipd.sdq.identifier.Identifier;

public interface ITransformationTrace {

	Optional<SEFFInstance> resolveSeffInstance(String id);

	Optional<DataOperationInstance> resolveDataOperationInstance(String id);

	Optional<DataType> resolveDataType(String id);

	/**
	 * Resolves the ID of a PCM {@link de.uka.ipd.sdq.identifier.Identifier}.
	 * 
	 * Please note that this method will not yield a result for identifiers that
	 * have to be instantiated (see other methods). Even if these identifiers are
	 * considered in the transformation, resolving them via their ID is not useful
	 * because the context always has to be considered as well.
	 * 
	 * @param id The ID of the identifier.
	 * @return The identifier element.
	 */
	Optional<Identifier> resolveIdentifier(String id);
}
