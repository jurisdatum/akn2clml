package com.jurisdatum.tna.akn2clml;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;
import javax.xml.transform.stream.StreamSource;

import com.jurisdatum.xml.Saxon;

import net.sf.saxon.s9api.Destination;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer;
import net.sf.saxon.s9api.Serializer.Property;
import net.sf.saxon.s9api.Xslt30Transformer;
import net.sf.saxon.s9api.XsltCompiler;
import net.sf.saxon.s9api.XsltExecutable;

public class Transform {
	
	private static final String stylesheet = "/transform/akn2clml.xsl";
	
	private static class Importer implements URIResolver {
		@Override public Source resolve(String href, String base) throws TransformerException {
			InputStream file = this.getClass().getResourceAsStream("/transform/" + href);
			return new StreamSource(file);
		}
	}

	private final XsltExecutable executable;
	
	public Transform() throws IOException {
		XsltCompiler compiler = Saxon.processor.newXsltCompiler();
		compiler.setURIResolver(new Importer());
		InputStream stream = this.getClass().getResourceAsStream(stylesheet);
		Source source = new StreamSource(stream);
		try {
			executable = compiler.compile(source);
		} catch (SaxonApiException e) {
			throw new RuntimeException(e);
		} finally {
			stream.close();
		}
	}
	
	private void transform(Source akn, Destination destination) {
		Xslt30Transformer transform = executable.load30();
		try {
			transform.transform(akn, destination);
		} catch (SaxonApiException e) {
			throw new RuntimeException(e);
		}
	}

	public void transform(Source akn, OutputStream output) {
		Serializer serializer = executable.getProcessor().newSerializer(output);
		serializer.setOutputProperty(Property.SAXON_SUPPRESS_INDENTATION, "{http://www.legislation.gov.uk/namespaces/legislation}Text");
		transform(akn, serializer);
	}

}
