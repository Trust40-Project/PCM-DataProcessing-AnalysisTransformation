package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics;

public interface IPrioritizable extends Comparable<IPrioritizable> {

	enum ProducedAssignmentType {
		DEFAULTS(10), DEFAULTS_SPECIFIC(20), ATTRIBUTES(50), VARIABLES(50), OTHER(100);

		private final int priority;

		ProducedAssignmentType(int priority) {
			this.priority = priority;
		}

		public int getPriotity() {
			return priority;
		}
	}

	default int getPriority() {
		return getProducedType().getPriotity();
	}

	ProducedAssignmentType getProducedType();

	@Override
	default int compareTo(IPrioritizable o) {
		// highest priority first
		return o.getPriority() - getPriority();
	}

}
