package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.tests.base;

import java.io.File;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.impl.EPackageRegistryImpl;
import org.eclipse.emf.ecore.plugin.EcorePlugin;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.ocl.ecore.OCL;
import org.eclipse.ocl.ecore.delegate.OCLDelegateDomain;
import org.eclipse.ocl.pivot.utilities.PivotStandaloneSetup;
import org.eclipse.ocl.xtext.completeocl.CompleteOCLStandaloneSetup;
import org.eclipse.ocl.xtext.essentialocl.EssentialOCLStandaloneSetup;
import org.modelversioning.emfprofile.Profile;
import org.palladiosimulator.pcm.dataprocessing.profile.api.Api;

public final class StandaloneInitializer {

	private static final boolean PLUGIN_TEST = EcorePlugin.IS_ECLIPSE_RUNNING;
	private static final String RELATIVE_PATH_PROFILE = "profile.emfprofile_diagram";
	private static final String PROJECT_NAME_TEST_BASE = "org.palladiosimulator.pcm.dataprocessing.analysis.transformation.tests.base";
	private static final String PROJECT_NAME_PROFILE = "org.palladiosimulator.pcm.dataprocessing.profile";
	
	private StandaloneInitializer() {
		// intentionally left blank
	}
	
	public static boolean isRunningEmbedded() {
		return PLUGIN_TEST;
	}
	
	public static boolean initStandalone() {
		if (!isRunningEmbedded()) {
			initNonEmbeddedPart();
		}

		EssentialOCLStandaloneSetup.doSetup();
		
		// PCM Data Profile
		ResourceSet rs = new ResourceSetImpl();
		URI profileURI = createPluginRelativeURI(PROJECT_NAME_PROFILE, RELATIVE_PATH_PROFILE);
		Profile profile = (Profile) rs.getResource(profileURI, true).getContents().get(0);
		EPackageRegistryImpl.INSTANCE.put(profile.getNsURI(), profile);
		
		return true;
	}

	private static void initNonEmbeddedPart() {
		// OCL Initialization
		OCL.initialize(null);
		OCLDelegateDomain.initialize(null);
		
		// OCL Pivot
		PivotStandaloneSetup.doSetup();
		CompleteOCLStandaloneSetup.doSetup();
		
		
//		EStructuralFeature.Internal.SettingDelegate.Factory.Registry.INSTANCE.put(DynamicDispatchEnabler.URI, DynamicDispatchEnablingOCLSettingDelegateFactory.createDefault());
//		EOperation.Internal.InvocationDelegate.Factory.Registry.INSTANCE.put(DynamicDispatchEnabler.URI, DynamicDispatchEnablingOCLInvocationDelegateFactory.createDefault());
//		EValidator.ValidationDelegate.Registry.INSTANCE.put(DynamicDispatchEnabler.URI, DynamicDispatchEnablingOCLValidationDelegateFactory.createDefault());
		
		
		// Detection of Meta Models and URIs by classpath magic
		// https://wiki.eclipse.org/EMF/FAQ#How_do_I_make_my_EMF_standalone_application_Eclipse-aware.3F
		EcorePlugin.ExtensionProcessor.process(null);

		// Resource URI Mapping
		registerProjectURI(Api.class, PROJECT_NAME_PROFILE);
		registerProjectURI(TransformationTestBase.class, PROJECT_NAME_TEST_BASE);
	}
	
	public static URI createPluginRelativeURI(String pluginName, String relativePath) {
		if (!isRunningEmbedded()) {
			return createProjectRelativeURI(pluginName, relativePath);
		}
		String uriString = String.format("/%s/%s", pluginName, relativePath);
		return URI.createPlatformPluginURI(uriString, false);
	}
	
	public static URI createProjectRelativeURI(String projectName, String relativePath) {
		String uriString = String.format("/%s/%s", projectName, relativePath);
		return URI.createPlatformResourceURI(uriString, false);
	}
	
	public static void registerProjectURI(Class<?> clz, String projectName) {
		if (isRunningEmbedded()) {
			return;
		}
		File location = getProjectLocation(clz, projectName);
		URI projectURI = URI.createFileURI(location.getAbsolutePath()).appendSegment("");
		EcorePlugin.getPlatformResourceMap().put(projectName, projectURI);
	}

	private static File getProjectLocation(Class<?> clz, String projectName) {
		String classLocation = clz.getProtectionDomain().getCodeSource().getLocation().getPath();
		String projectLocation = classLocation.substring(0, classLocation.indexOf(projectName) + projectName.length());
		return new File(projectLocation);
	}
}
