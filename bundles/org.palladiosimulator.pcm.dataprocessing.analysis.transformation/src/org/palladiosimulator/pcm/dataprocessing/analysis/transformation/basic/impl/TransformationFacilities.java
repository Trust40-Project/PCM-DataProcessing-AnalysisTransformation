package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.basic.impl;

import java.util.List;
import java.util.Map;

import org.eclipse.emf.ecore.EObject;
import org.palladiosimulator.pcm.core.composition.AssemblyContext;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.naming.wrappers.IdentifierInstance;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.naming.wrappers.SEFFInstance;
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.data.Data;
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.processing.DataOperation;
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.Caller;
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.LogicTerm;
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.Operation;
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.OperationCall;
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.Variable;
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.VariableAssignment;
import org.palladiosimulator.pcm.resourceenvironment.ResourceContainer;

public interface TransformationFacilities {

	org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.System getSystem();

	Operation getOperation(IdentifierInstance<DataOperation, AssemblyContext> dataOpInstance);
	
	Operation getOperation(IdentifierInstance<DataOperation, AssemblyContext> dataOpInstance, EObject propertySource);

	Operation getSEFFOperation(SEFFInstance seffInstance);

	OperationCall getOperationCall(Caller from, Operation to);

	Variable getReturnVariable(Data data, IdentifierInstance<?, ?> instance);

	Variable getStateVariable(Data data, IdentifierInstance<?, ?> instance);

	List<VariableAssignment> createReturnValueAssignments(IdentifierInstance<DataOperation, AssemblyContext> opInstance,
			Map<Data, LogicTerm> availableData);

	ResourceContainer getResourceContainer(AssemblyContext ac);
}
