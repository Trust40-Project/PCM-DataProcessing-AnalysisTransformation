package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.basic.impl

import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.annotations.Delegate
import org.palladiosimulator.pcm.repository.DataType
import org.palladiosimulator.pcm.repository.PrimitiveDataType

@Data
class DataTypeWrapper implements DataType {

	@Delegate val DataType delegate

	new(DataType type) {
		delegate = type
	}

	override hashCode() {
		if (delegate instanceof PrimitiveDataType) {
			return delegate.type.hashCode
		}
		delegate.hashCode
	}

	override equals(Object o) {
		o instanceof DataType && o.hashCode === hashCode
	}
}
