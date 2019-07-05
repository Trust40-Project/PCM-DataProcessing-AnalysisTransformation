package org.palladiosimulator.pcm.dataprocessing.analysis.transformation;

import org.eclipse.core.runtime.Plugin;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceReference;
import org.palladiosimulator.pcm.dataprocessing.analysis.transformation.basic.ITransformatorFactory;

public class Activator extends Plugin {

	private static Activator instance;
	
	private ITransformatorFactory transformatorFactory;

	@Override
	public void start(BundleContext context) throws Exception {
		super.start(context);
		setInstance(this);
		
		ServiceReference<ITransformatorFactory> factoryReference = context.getServiceReference(ITransformatorFactory.class);
		this.transformatorFactory = context.getService(factoryReference);
	}

	@Override
	public void stop(BundleContext context) throws Exception {
		setInstance(null);
		super.stop(context);
	}

	private static void setInstance(Activator instance) {
		Activator.instance = instance;
	}
	
	public static Activator getInstance() {
		return Activator.instance;
	}

	public ITransformatorFactory getTransformatorFactoryInstance() {
		return transformatorFactory;
	}
}
