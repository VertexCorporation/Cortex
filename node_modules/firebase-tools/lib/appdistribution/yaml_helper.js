"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.toYaml = toYaml;
exports.fromYamlStep = fromYamlStep;
exports.fromYaml = fromYaml;
const jsYaml = require("js-yaml");
const error_1 = require("../error");
const ALLOWED_YAML_STEP_KEYS = new Set(["goal", "hint", "finalScreenAssertion"]);
const ALLOWED_YAML_TEST_CASE_KEYS = new Set([
    "displayName",
    "id",
    "prerequisiteTestCaseId",
    "steps",
]);
function extractIdFromResourceName(name) {
    return name.split("/").pop() ?? "";
}
function toYamlTestCases(testCases) {
    return testCases.map((testCase) => ({
        displayName: testCase.displayName,
        id: extractIdFromResourceName(testCase.name),
        ...(testCase.prerequisiteTestCase && {
            prerequisiteTestCaseId: extractIdFromResourceName(testCase.prerequisiteTestCase),
        }),
        steps: testCase.aiInstructions.steps.map((step) => ({
            goal: step.goal,
            ...(step.hint && { hint: step.hint }),
            ...(step.successCriteria && {
                finalScreenAssertion: step.successCriteria,
            }),
        })),
    }));
}
function toYaml(testCases) {
    return jsYaml.dump({ tests: toYamlTestCases(testCases) });
}
function castExists(it, thing) {
    if (it == null) {
        throw new error_1.FirebaseError(`"${thing}" is required`);
    }
    return it;
}
function checkAllowedKeys(allowedKeys, o) {
    for (const key of Object.keys(o)) {
        if (!allowedKeys.has(key)) {
            throw new error_1.FirebaseError(`unexpected property "${key}"`);
        }
    }
}
function fromYamlStep(yamlStep) {
    checkAllowedKeys(ALLOWED_YAML_STEP_KEYS, yamlStep);
    return {
        goal: castExists(yamlStep.goal, "goal"),
        ...(yamlStep.hint && { hint: yamlStep.hint }),
        ...(yamlStep.finalScreenAssertion && {
            successCriteria: yamlStep.finalScreenAssertion,
        }),
    };
}
function fromYamlTestCases(appName, yamlTestCases) {
    return yamlTestCases.map((yamlTestCase) => {
        checkAllowedKeys(ALLOWED_YAML_TEST_CASE_KEYS, yamlTestCase);
        return {
            displayName: castExists(yamlTestCase.displayName, "displayName"),
            aiInstructions: {
                steps: castExists(yamlTestCase.steps, "steps").map((yamlStep) => fromYamlStep(yamlStep)),
            },
            ...(yamlTestCase.id && {
                name: `${appName}/testCases/${yamlTestCase.id}`,
            }),
            ...(yamlTestCase.prerequisiteTestCaseId && {
                prerequisiteTestCase: `${appName}/testCases/${yamlTestCase.prerequisiteTestCaseId}`,
            }),
        };
    });
}
function fromYaml(appName, yaml) {
    let parsedYaml;
    try {
        parsedYaml = jsYaml.load(yaml);
    }
    catch (err) {
        throw new error_1.FirebaseError(`Failed to parse YAML: ${(0, error_1.getErrMsg)(err)}`);
    }
    if (!parsedYaml || typeof parsedYaml !== "object" || !("tests" in parsedYaml)) {
        throw new error_1.FirebaseError("YAML file must contain a top-level 'tests' field with a list of test cases.");
    }
    const yamlTestCases = parsedYaml.tests;
    if (!Array.isArray(yamlTestCases)) {
        throw new error_1.FirebaseError("The 'tests' field in the YAML file must contain a list of test cases.");
    }
    return fromYamlTestCases(appName, yamlTestCases);
}
