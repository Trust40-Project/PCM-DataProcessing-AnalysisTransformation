package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.tests.base;

import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.not;
import static org.hamcrest.Matchers.nullValue;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.junit.Assert.fail;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.Collection;

import org.eclipse.emf.common.util.Diagnostic;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.compare.Comparison;
import org.eclipse.emf.compare.utils.EMFComparePrettyPrinter;
import org.junit.Before;
import org.junit.BeforeClass;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.basic.ITransformator;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.basic.impl.TransformatorFactoryImpl;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics.IReturnValueAssignmentGenerator;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics.IReturnValueAssignmentGeneratorRegistry;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics.impl.DefaultReturnValueAssignmentGenerator;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics.impl.UserDefinedReturnValueAssignmentsGenerator;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.naming.impl.HumanReadableUniqueNameProvider;
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.OperationCall;
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.PrologmodelPackage;
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.ReturnValueRef;
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.StateRef;
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.Variable;
import org.palladiosimulator.pcm.dataprocessing.prolog.prologmodel.VariableAssignment;

public abstract class TransformationTestBase {

	private final String testProjectName;
	private ITransformator subject;

	protected TransformationTestBase(String testProjectName) {
		StandaloneInitializer.registerProjectURI(getClass(), testProjectName);
		this.testProjectName = testProjectName;
	}

	@BeforeClass
	public static void init() {
		StandaloneInitializer.initStandalone();
	}

	@Before
	public void setup() {
		IReturnValueAssignmentGeneratorRegistry registry = new IReturnValueAssignmentGeneratorRegistry() {
			@Override
			public Iterable<IReturnValueAssignmentGenerator> getGenerators() {
				Collection<IReturnValueAssignmentGenerator> generators = new ArrayList<>();
				generators.add(new DefaultReturnValueAssignmentGenerator());
				generators.add(new UserDefinedReturnValueAssignmentsGenerator());
				generators.addAll(getAdditionalGenerators());
				return generators;
			}
		};
		TransformatorFactoryImpl factory = new TransformatorFactoryImpl();
		subject = factory.create(registry, new HumanReadableUniqueNameProvider());
//		subject = factory.create(registry, null);
	}

	protected ITransformator getSubject() {
		return subject;
	}

	protected abstract Collection<IReturnValueAssignmentGenerator> getAdditionalGenerators();

	protected static void assertFullCopy(VariableAssignment assignment, Variable targetVariable,
			Variable sourceVariable) {
		assertFullCopy(assignment, targetVariable, sourceVariable, null);
	}

	protected static void assertFullCopy(VariableAssignment assignment, Variable targetVariable,
			Variable sourceVariable, OperationCall sourceCall) {
		assertThat(assignment.getVariable(), is(targetVariable));
		assertThat(assignment.getAttribute(), is(nullValue()));
		assertThat(assignment.getValue(), is(nullValue()));
		if (assignment.getTerm() instanceof ReturnValueRef) {
			assertThat(sourceVariable.eContainmentFeature(), is(PrologmodelPackage.Literals.OPERATION__RETURN_VALUES));
			ReturnValueRef ref = (ReturnValueRef) assignment.getTerm();
			assertThat(ref.getReturnValue(), is(sourceVariable));
			assertThat(ref.getAttribute(), is(nullValue()));
			assertThat(ref.getValue(), is(nullValue()));
			assertThat(sourceCall, is(not(nullValue())));
			assertThat(ref.getCall(), is(sourceCall));
		} else if (assignment.getTerm() instanceof StateRef) {
			assertThat(sourceVariable.eContainmentFeature(),
					is(PrologmodelPackage.Literals.OPERATION__STATE_VARIABLES));
			StateRef ref = (StateRef) assignment.getTerm();
			assertThat(ref.getStateVariable(), is(sourceVariable));
			assertThat(ref.getAttribute(), is(nullValue()));
			assertThat(ref.getValue(), is(nullValue()));
			assertThat(sourceCall, is(nullValue()));
		} else {
			fail("The assignment term has to refer to a state or return variable.");
		}
	}

	protected URI createRelativeURI(String relativePath) {
		if (StandaloneInitializer.isRunningEmbedded()) {
			return URI.createFileURI(new File(relativePath).getAbsolutePath());
		}
		return StandaloneInitializer.createProjectRelativeURI(testProjectName, relativePath);
	}

	protected static String toString(Diagnostic diagnostic) {
		Collection<Diagnostic> children = diagnostic.getChildren();
		StringBuilder sb = new StringBuilder(diagnostic.getMessage());
		for (Diagnostic diagnosticChildren : children) {
			sb.append(java.lang.System.lineSeparator());
			sb.append(diagnosticChildren.getMessage());
		}
		return sb.toString();
	}
	

	protected static String toString(Comparison comparison) throws IOException {
		try (OutputStream baos = new ByteArrayOutputStream()) {
			try (PrintStream ps = new PrintStream(baos)) {
				EMFComparePrettyPrinter.printComparison(comparison, ps);
				return baos.toString();
			}
		}
	}
}
