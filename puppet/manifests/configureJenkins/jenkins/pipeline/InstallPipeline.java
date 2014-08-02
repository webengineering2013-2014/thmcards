package jenkins.pipeline;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;

import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.Select;
import org.openqa.selenium.support.ui.WebDriverWait;

// Author: Roman Domnich ( workaddr [ at ] yahoo.de )

public class InstallPipeline {

	private static final String IT_SHELL = "command";
	private static final String IT_PYTHON = "_.command";

	private static final String PLUGINS_SCRIPTS_PATH_BASE = "/vagrant/puppet/manifests/configureJenkins/";

	public static void main(String[] args) throws FileNotFoundException {

		// wait for a maximum of 420 seconds for the site to load.

		new InstallPipeline("http://localhost:8090/", (short) 420);

	}

	private WebDriverWait webDriverWait;
	private FirefoxDriver firefoxDriver;

	private String JENKINS_URL_BASE;

	public InstallPipeline(String jenkinsURLBase, short timeout)
			throws FileNotFoundException {

		JENKINS_URL_BASE = jenkinsURLBase;

		firefoxDriver = new FirefoxDriver();

		webDriverWait = new WebDriverWait(firefoxDriver, timeout);

		// get a session cookie

		firefoxDriver.get(JENKINS_URL_BASE);

		createBuildStage();

		createTestStage();

		createAnalyzeAndReportStage();

		createDeployStage();

		// create the new pipeline view

		firefoxDriver.get(JENKINS_URL_BASE + "newView");

		WebElement viewName = webDriverWait.until(ExpectedConditions
				.visibilityOfElementLocated(By.id("name")));

		viewName.sendKeys("THMcards Pipeline");

		for (WebElement label : webDriverWait.until(ExpectedConditions
				.visibilityOfAllElementsLocatedBy(By.tagName("label"))))
			if (label.getText().contains("Pipeline")) {

				webDriverWait.until(
						ExpectedConditions.elementToBeClickable(label)).click();

				break;

			}

		viewName.submit();

		WebElement firstJob = webDriverWait.until(ExpectedConditions
				.visibilityOfElementLocated(By
						.cssSelector("select[name=\"_.firstJob\"]")));

		new Select(firstJob).selectByVisibleText("Build");

		new Select(
				webDriverWait.until(ExpectedConditions.visibilityOfElementLocated(By
						.cssSelector("select[name=\"_.noOfDisplayedBuilds\"]"))))
				.selectByVisibleText("10");

		firstJob.submit();

		// notify pexpect in ../../configure.py that the Jenkins - Pipeline has been installed.
		System.out.print("PIPELINEINSTALLED");

	}

	// adds a shell- or a python-script

	private WebElement addStageInstructions(String instructionTypePattern,
			String instructionsFileName, String instructionsType)
			throws FileNotFoundException {

		webDriverWait.until(
				ExpectedConditions.elementToBeClickable(webDriverWait
						.until(ExpectedConditions.visibilityOfElementLocated(By
								.id("yui-gen3-button"))))).click();

		clickOnSpecificInstructionTypeLinkFromTypesMenu(instructionTypePattern,
				"yui-gen4");

		WebElement commandTextfield = webDriverWait.until(ExpectedConditions
				.visibilityOfElementLocated(By.name(instructionsType)));

		Scanner s = new Scanner(new File(instructionsFileName));
		commandTextfield.sendKeys(s.useDelimiter("\\Z").next());
		s.close();

		return commandTextfield;

	}

	private void clickOnSpecificInstructionTypeLinkFromTypesMenu(
			String instructionTypePattern, String instructionTypesId) {

		clickOnSpecificInstructionTypeLinkFromTypesMenu(instructionTypePattern,
				instructionTypesId, false);

	}

	private void clickOnSpecificInstructionTypeLinkFromTypesMenu(
			String instructionTypePattern, String instructionTypesId,
			boolean exactPatternMatch) {

		WebElement instructionTypes = webDriverWait.until(ExpectedConditions
				.visibilityOfElementLocated(By.id(instructionTypesId)));

		for (WebElement elem : instructionTypes.findElements(By
				.cssSelector("a.yuimenuitemlabel"))) {

			boolean patternMatched = false;

			if (exactPatternMatch)
				patternMatched = elem.getText().toLowerCase()
						.equals(instructionTypePattern);
			else
				patternMatched = elem.getText().toLowerCase()
						.contains(instructionTypePattern);

			if (patternMatched) {

				elem.click();

				break;

			}

		}

	}

	private void createAnalyzeAndReportStage() {

		setStageNameAndType("Analyze and Report");

		putAfterProject("Test");

		setSourceForPerformanceReport("../../Test/workspace/testthmcards/thmcards_log.jtl");

	}

	private void createBuildStage() throws FileNotFoundException {

		setStageNameAndType("Build");

		setStageWorkingDirectory("/vagrant");

		WebElement commandTextfield = addStageInstructions("python",
				PLUGINS_SCRIPTS_PATH_BASE + "JenkinsBuild.txt", IT_PYTHON);

		commandTextfield.submit();

	}

	private void createDeployStage() throws FileNotFoundException {

		setStageNameAndType("Deploy");

		putAfterProject("Analyze and Report");

		setStageWorkingDirectory("/vagrant/puppet/manifests/cctrl");

		WebElement commandTextfield = addStageInstructions("python",
				PLUGINS_SCRIPTS_PATH_BASE + "JenkinsDeploy.txt", IT_PYTHON);

		commandTextfield.submit();

	}

	private void createTestStage() throws FileNotFoundException {

		setStageNameAndType("Test");

		useXvnc();

		putAfterProject("Build");

		WebElement commandTextfield = addStageInstructions("shell",
				PLUGINS_SCRIPTS_PATH_BASE + "JenkinsTest.txt", IT_SHELL);

		commandTextfield.submit();

	}

	private void putAfterProject(String nameOfpreviousProject) {

		webDriverWait.until(
				ExpectedConditions.elementToBeClickable(By.id("cb17"))).click();

		webDriverWait.until(
				ExpectedConditions.visibilityOfElementLocated(By
						.name("_.upstreamProjects"))).sendKeys(
				nameOfpreviousProject);

	}

	private void setSourceForPerformanceReport(String reportFileName) {

		webDriverWait.until(
				ExpectedConditions.elementToBeClickable(webDriverWait
						.until(ExpectedConditions.visibilityOfElementLocated(By
								.id("yui-gen5-button"))))).click();

		clickOnSpecificInstructionTypeLinkFromTypesMenu("performance",
				"yui-gen6");

		webDriverWait.until(
				ExpectedConditions.elementToBeClickable(webDriverWait
						.until(ExpectedConditions.visibilityOfElementLocated(By
								.id("yui-gen44-button"))))).click();

		clickOnSpecificInstructionTypeLinkFromTypesMenu("jmeter", "yui-gen45",
				true);

		WebElement reportFileField = webDriverWait.until(ExpectedConditions
				.visibilityOfElementLocated(By
						.cssSelector("input[name=\"_.glob\"]")));

		reportFileField.sendKeys(reportFileName);
		reportFileField.submit();

	}

	private void setStageNameAndType(String stageName_) {

		firefoxDriver.get(JENKINS_URL_BASE + "newJob");

		WebElement stageName = webDriverWait.until(ExpectedConditions
				.visibilityOfElementLocated(By.id("name")));

		stageName.sendKeys(stageName_);

		webDriverWait
				.until(ExpectedConditions.elementToBeClickable(webDriverWait
						.until(ExpectedConditions
								.presenceOfAllElementsLocatedBy(By
										.cssSelector("input[type=\"radio\"]")))
						.get(0))).click();

		stageName.submit();

	}

	private void setStageWorkingDirectory(String stageWorkDir) {

		webDriverWait.until(
				ExpectedConditions.elementToBeClickable(By
						.id("yui-gen7-button"))).click();

		webDriverWait.until(
				ExpectedConditions.elementToBeClickable(webDriverWait
						.until(ExpectedConditions.presenceOfElementLocated(By
								.id("cb14"))))).click();

		webDriverWait.until(
				ExpectedConditions.visibilityOf(webDriverWait
						.until(ExpectedConditions.presenceOfElementLocated(By
								.name("customWorkspace.directory")))))
				.sendKeys(stageWorkDir);

	}

	private void useXvnc() {

		webDriverWait.until(
				ExpectedConditions.elementToBeClickable(webDriverWait
						.until(ExpectedConditions.presenceOfElementLocated(By
								.id("cb20"))))).click();

		webDriverWait.until(
				ExpectedConditions.elementToBeClickable(webDriverWait
						.until(ExpectedConditions.presenceOfElementLocated(By
								.name("_.takeScreenshot"))))).click();

	}

}
