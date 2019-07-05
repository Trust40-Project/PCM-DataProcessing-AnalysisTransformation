package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.rbac.tests;

import static org.hamcrest.Matchers.empty;
import static org.hamcrest.Matchers.is;
import static org.junit.Assert.assertThat;

import java.io.IOException;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Optional;

import org.eclipse.emf.compare.Comparison;
import org.eclipse.emf.compare.EMFCompare;
import org.eclipse.emf.compare.scope.DefaultComparisonScope;
import org.eclipse.emf.compare.scope.IComparisonScope;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.palladiosimulator.pcm.allocation.Allocation;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.characteristics.IReturnValueAssignmentGenerator;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.rbac.characteristics.DefaultRBACReturnValueAssignmentGenerator;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.tests.base.TransformationTestBase;
import org.palladiosimulator.pcm.dataprocessing.dataprocessing.characteristics.CharacteristicTypeContainer;
import org.palladiosimulator.pcm.usagemodel.UsageModel;

public abstract class RBACTransformationTestBase extends TransformationTestBase {

	public RBACTransformationTestBase() {
		super("org.palladiosimulator.pcm.dataprocessing.analysis.transformation.rbac.tests");
	}

	@Override
	protected Collection<IReturnValueAssignmentGenerator> getAdditionalGenerators() {
		return Arrays.asList(new DefaultRBACReturnValueAssignmentGenerator());
	}

	interface ModelModifier {
		public void modify(UsageModel um, org.palladiosimulator.pcm.system.System sys, Allocation am, CharacteristicTypeContainer ctc);
	}
	
	protected void runComparingTransformationTest(String folderName) throws IOException {
		runComparingTransformationTest(folderName, Optional.empty(), Optional.empty(), Optional.empty());
	}
	
	protected void runComparingTransformationTest(String folderName, Optional<ModelModifier> modelModifier, Optional<String> expectedName, Optional<String> resultFileName) throws IOException {
		String modelFolderName = "models/" + folderName + "/";
		ResourceSet rs = new ResourceSetImpl();
		UsageModel usageModel = (UsageModel) rs
				.getResource(createRelativeURI(modelFolderName + "default.usagemodel"), true)
				.getContents().get(0);
		org.palladiosimulator.pcm.system.System system = (org.palladiosimulator.pcm.system.System) rs
				.getResource(createRelativeURI(modelFolderName + "default.system"), true).getContents()
				.get(0);
		Allocation allocationModel = (Allocation) rs
				.getResource(createRelativeURI(modelFolderName + "default.allocation"), true)
				.getContents().get(0);
		CharacteristicTypeContainer characteristicTypeContainer = (CharacteristicTypeContainer) rs
				.getResource(createRelativeURI(modelFolderName + "characteristicTypes.xmi"), true)
				.getContents().get(0);
		EcoreUtil.resolveAll(rs);
		
		modelModifier.ifPresent(m -> m.modify(usageModel, system, allocationModel, characteristicTypeContainer));
			
		EObject actual = getSubject().transform(usageModel, system,
				allocationModel, characteristicTypeContainer);

		if (resultFileName.isPresent()) {
			Resource r = rs.createResource(createRelativeURI(modelFolderName + resultFileName.get()));
			r.getContents().add(actual);
			r.save(Collections.emptyMap());			
		}
		
		EObject expected = rs.getResource(createRelativeURI(modelFolderName + expectedName.orElse("expected.xmi")), true).getContents().get(0);
		IComparisonScope scope = new DefaultComparisonScope(expected, actual, null);
		Comparison comparison = EMFCompare.builder().build().compare(scope);

		assertThat(toString(comparison), comparison.getDifferences(), is(empty()));
	}
	
}
