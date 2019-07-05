package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.rbac.characteristics;

import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.osgi.service.component.annotations.Component;
import org.palladiosimulator.pcm.core.composition.AssemblyContext;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics.IQueryExecutor;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics.IReturnValueAssignmentGenerator;
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.data.Data;
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.processing.DataOperation;
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.LogicTerm;
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.Variable;
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.VariableAssignment;

@Component
public class DefaultRBACReturnValueAssignmentGenerator implements IReturnValueAssignmentGenerator {

	private static final String CHARACTERISTIC_NAME_ROLE = "Roles";
	private static final String CHARACTERISTIC_NAME_RIGHTS = "AccessRights";
	
	@Override
	public ProducedAssignmentType getProducedType() {
		return ProducedAssignmentType.DEFAULTS_SPECIFIC;
	}

	@Override
	public List<VariableAssignment> generateAssignments(IQueryExecutor queryExecutor, Optional<AssemblyContext> ac,
			DataOperation dataOperation, Map<Data, LogicTerm> availableData, Map<Data, Variable> returnVariables) {
		DataProcessorSwitch generatorSwitch = new DataProcessorSwitch(queryExecutor, ac, availableData, returnVariables, CHARACTERISTIC_NAME_ROLE, CHARACTERISTIC_NAME_RIGHTS);
		return generatorSwitch.doSwitch(dataOperation);		
	}

}
