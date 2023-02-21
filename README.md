# Timestamp Converter Variable for Google Tag Manager Server Container

## Ways to use Timestamp Converter Variable

#### Step 1: Create a new variable in your Google Tag Manager Server Container.
1. Clone or download this repository.
2. Go to your Google Tag Manager Server Container and go to the `Templates` tab on the left menu.
3. Create a new `Variable Template` by clicking on the `New` button. This will open the `Template Editor`.
4. On the `Template Editor` page, click on the `Import` button and select the `template.tpl` file from the repository.
5. Click on the `Save` button.

#### Step 2: Setting up the user-defined variable.
1. Go to the `Variables` tab on the left menu.
2. Create a new `User-Defined Variable` by clicking on the `New` button. This will open the `Variable Editor`.
3. On the `Variable Editor` page, select the `Timestamp Converter` template from the `Variable Type` dropdown.
4. Choose a Conversion Type from the `Conversion Type`. The available options are `Timestamp to ISO` and `ISO to Timestamp`.
5. Enter `current_timestamp` if you want to get the current timestamp and generate it dynamically.

#### Step 3: Using the variable in your Custom tag template.
1. Go to the `Templates` tab on the left menu and open your custom tag template.
2. Add a new field to your custom tag template with a name like `timestamp` or `event_at` and save.
3. Go to the `Tags` tab on the left menu and open your custom tag.
4. Within your custom tag, fields you now will the field you have added. 
5. Attach the custom user-defined variable you have created in step 2 to that field.

## Open Source

Initial development of timestamp <-> ISO was done by [Ram Manohar](https://www.linkedin.com/in/rammanoharbokkisa/).

Timestamp Converter Variable for GTM Server is developing and maintained by [Stape Team](https://stape.io/) under the Apache 2.0 license.
