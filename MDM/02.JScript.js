/**
 * @description HR Master Code Management Logic
 * This script contains UI logic for managing categories and detail items of HR master codes.
 * Selecting a main category (Category) filters and displays the corresponding detail codes (Detail) in the bottom grid.
 */

// Define grid and data control objects
var mainGrid = Matrix.getObject("DataGrid");        // Main category information grid
var detailGrid = Matrix.getObject("DataGrid1");     // Sub-detail code information grid
var subCodeParam = Matrix.getObject("VS_SUBCODE");  // Parameter variable for querying the sub-grid
var userLabel = Matrix.getObject("LB_사번");         // Label to display user information

/*****************************************
 * Executed upon page load completion
 * - Initial data loading and user session information setup
 *****************************************/
var OnLoadComplete = function(sender, args) {
    // Queries main category data from the server upon entering the page.
    Matrix.doRefresh("mainGrid"); 
    
    // Binds the currently logged-in user's ID to the label. (For Audit Trail purposes)
    userLabel.Text = Matrix.GetUserInfo().UserCode;
};

/*****************************************
 * Button control click event handler
 * - Handles common logic such as Search, Save, Add, etc.
 *****************************************/
var OnButtonClick = function(sender, args) {

    // 1. Data Retrieval (Search)
    if (args.Id == "btn_MainSearch") {
        Matrix.doRefresh("mainGrid");
    } 
    
    // 2. Save Main Grid Data (Save)
    else if (args.Id == "btn_MainSave") {
        if (mainGrid.IsModified()) {
            // Executes the server's update plan (Process) if there is modified data.
            Matrix.ExecutePlan("PROCESS_SAVE_MAIN", "", function(p) {
                if (p.Success == false) {
                    Matrix.Alert(p.Message);
                    return;
                }
                mainGrid.ClearRowState(); // Reset modified status upon successful save
                Matrix.Information("Save completed.", "Information");
                Matrix.doRefresh("mainGrid");
            });
        } else {
            alert("No changes have been made.");
        }
    }

    // 3. Save Sub-Detail Grid Data (Save)
    else if (args.Id == "btn_DetailSave") {
        if (detailGrid.IsModified()) {
            Matrix.ExecutePlan("PROCESS_SAVE_DETAIL", "", function(p) {
                if (p.Success == false) {
                    Matrix.Alert(p.Message);
                    return;
                }
                detailGrid.ClearRowState();
                Matrix.Information("Save completed.", "Information");
                Matrix.doRefresh("detailGrid");
            });
        } else {
            alert("No changes have been made.");
        }
    }

    // 4. Add Row (Add)
    else if (args.Id == "btn_MainAdd") {
        mainGrid.AppendRow(); // Create a new row in the main grid
    } 
    else if (args.Id == "btn_DetailAdd") {
        detailGrid.AppendRow(); // Create a new row in the detail grid
    }

    // 5. Delete Row (Delete)
    else if (args.Id == "btn_DetailDelete") {
        Matrix.Confirm("Are you sure you want to delete the selected records?", "Delete Confirmation", function(isOk) {
            if (isOk) {
                detailGrid.RemoveRow(); // Delete selected detail grid row
            }
        });
    }
};

/*****************************************
 * Grid cell click event handler
 * - Dynamically loads detail sub-information when a specific row is clicked in the main grid.
 * - Dynamically changes sub-grid header titles according to main grid configuration values (VALUE1~10).
 *****************************************/
var OnCellClick = function(sender, args) {
    // Link sub-detail information only when the 'DetailCode' column is clicked.
    if (args.Field.Caption == "DetailCode") {
        if (args.Id == "mainGrid") {
            
            // Assign the DetailCode value of the clicked row to the sub-grid query parameter
            subCodeParam.Text = args.Row.GetCell("DetailCode").Value;
            Matrix.doRefresh("detailGrid"); // Refresh sub-grid based on parameter

            /**
             * [Dynamic Header Mapping]
             * Applies variable attribute values (VALUE1~10) defined in upper code definition as column headers (Caption) of the sub-grid.
             * This allows different attribute names per code to be reflected dynamically in the UI.
             */
            for (var i = 1; i <= 10; i++) {
                var metaValue = args.Row.GetValue("VALUE" + i);
                
                // If a column name is defined in the main category, use that title; otherwise, retain default field name.
                if (metaValue != "" && metaValue != null) {
                    detailGrid.GetField("VALUE" + i).Caption = metaValue;
                } else {
                    // Copy default caption from main grid to maintain consistency when data is absent.
                    detailGrid.GetField("VALUE" + i).Caption = mainGrid.GetField("VALUE" + i).Caption;
                }
            }
            
            // Reflect modified UI layout (header titles) onto the grid.
            detailGrid.Update();
        }
    }
};
