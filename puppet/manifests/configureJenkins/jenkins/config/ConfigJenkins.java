package jenkins.config;

import java.util.ArrayList;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

// Author: Roman Domnich ( workaddr [ at ] yahoo.de )

public class ConfigJenkins {

	public static void main(String[] args) {
		String JENKINS_URL_BASE = "http://localhost:8090/";

		WebDriver w = new FirefoxDriver();

		// wait for a maximum of 420 seconds for the site to load.

		WebDriverWait wait = new WebDriverWait(w, 420);

		// get a session cookie

		w.get(JENKINS_URL_BASE);

		// set the minimal temporary free space threshold

		w.get(JENKINS_URL_BASE + "computer/configure");

		WebElement freeSpaceThreshold = wait.until(
				ExpectedConditions.visibilityOfAllElementsLocatedBy(By
						.cssSelector("input[name=\"_.freeSpaceThreshold\"]")))
				.get(1);

		freeSpaceThreshold.clear();
		freeSpaceThreshold.sendKeys("50MB");
		freeSpaceThreshold.submit();

		// set the number of executors on master node

		w.get(JENKINS_URL_BASE + "computer/(master)/configure");

		WebElement numExecutors = wait.until(ExpectedConditions
				.visibilityOfElementLocated(By
						.cssSelector("input[name=\"_.numExecutors\"]")));

		numExecutors.clear();
		numExecutors.sendKeys("1");
		numExecutors.submit();

		// update plugin view until plugins are available in view

		while (true) {

			w.get(JENKINS_URL_BASE + "pluginManager/advanced");

			wait.until(
					ExpectedConditions.elementToBeClickable(By
							.id("yui-gen5-button"))).click();

			wait.until(ExpectedConditions.visibilityOfElementLocated(By
					.id("completionMarker")));

			w.get(JENKINS_URL_BASE + "pluginManager/available");

			if (w.findElements(
					By.cssSelector("input[name=\"plugin.build-pipeline-plugin.default\"]"))
					.size() > 0)
				break;

		}

		// install all necessary plugins

		String[] pluginNames = { "plugin.build-pipeline-plugin.default",
				"plugin.python.default", "plugin.performance.default",
				"plugin.xvnc.default" };

		ArrayList<WebElement> plugins = new ArrayList<WebElement>();

		for (String pluginName : pluginNames)
			plugins.addAll(wait.until(ExpectedConditions
					.visibilityOfAllElementsLocatedBy(By
							.cssSelector("input[name=\"" + pluginName + "\"]"))));

		for (WebElement plugin : plugins)
			wait.until(ExpectedConditions.elementToBeClickable(plugin)).click();

		wait.until(
				ExpectedConditions.elementToBeClickable(By
						.id("yui-gen2-button"))).click();
		wait.until(
				ExpectedConditions.elementToBeClickable(By
						.id("scheduleRestartCheckbox"))).click();

		// notify pexpect in ../../configure.py that Jenkins has been configured.
		System.out.print("JENKINSCONFIGURED");

	}

}
