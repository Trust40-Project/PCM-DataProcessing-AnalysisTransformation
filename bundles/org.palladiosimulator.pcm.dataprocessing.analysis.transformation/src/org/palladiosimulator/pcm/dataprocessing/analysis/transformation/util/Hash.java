package org.palladiosimulator.pcm.dataprocessing.analysis.transformation.util;

import java.util.zip.Adler32;

public class Hash {

	private final Adler32 algorithm = new Adler32();
	
	public static Hash init(String str) {
		Hash hash = new Hash();
		hash.add(str);
		return hash;
	}
	
	public Hash add(String str) {
		algorithm.update(str.getBytes());
		return this;
	}
	
	public String getHash() {
		return Long.toHexString(algorithm.getValue());
	}
	
}
