package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.dto;

import org.jgrapht.graph.DefaultEdge;
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.data.Data;
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.processing.DataOperation;

public class DataEdge extends DefaultEdge {

	private static final long serialVersionUID = -3265324551699993316L;
	
	private final Data data;

	public DataEdge(Data data) {
		super();
		this.data = data;
	}
	
	public DataOperation findSource() {
		return (DataOperation)super.getSource();
	}
	
	public DataOperation findTarget() {
		return (DataOperation)super.getTarget();
	}
	
	public Data getData() {
		return data;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((data == null) ? 0 : data.hashCode());
		result = prime * result + ((getSource() == null) ? 0 : getSource().hashCode());
		result = prime * result + ((getTarget() == null) ? 0 : getTarget().hashCode());
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
		DataEdge other = (DataEdge) obj;
		if (data == null) {
			if (other.data != null)
				return false;
		} else if (!data.equals(other.data))
			return false;
		if (getSource() == null) {
			if (other.getSource() != null)
				return false;
		} else if (!getSource().equals(other.getSource()))
			return false;
		if (getTarget() == null) {
			if (other.getTarget() != null)
				return false;
		} else if (!getTarget().equals(other.getTarget()))
			return false;
		return true;
	}

}
